const _cell_id_delimiter = "# ╔═╡ "
const _proj_uuid = Base.UUID(1)
const _manifest_uuid = Base.UUID(2)

function parse_notebook_cells(file)
    open(file) do io
        nlines = 1
        out = Tuple{Base.UUID, Int, String}[] 
        # Drop the preamble
        preamble = readuntil(io, _cell_id_delimiter)
        nlines += count('\n', preamble)
        while !eof(io)
            parsed_id = readline(io) |> String
            startswith(parsed_id, "Cell order") && break
            cell_uuid = Base.UUID(parsed_id)
            (cell_uuid === _proj_uuid || cell_uuid === _manifest_uuid) && break
            parsed_code = readuntil(io, _cell_id_delimiter)
            push!(out, (cell_uuid, nlines, parsed_code))
            nlines += count('\n', parsed_code) + 1 # +1 is for the line of the cell uuid
        end
        out
    end
end

# Store the list of struct definition and an array of Expr defining methods
@kwdef struct NotebookDefinitions
    structdefs::Set{Symbol} = Set{Symbol}()
    funcdefexprs::Vector{Expr} = Expr[]
end

modify_lnn(lnn::LineNumberNode; file, start_line) = LineNumberNode(lnn.line + start_line, file)
function  modify_lnn!(expr::Expr; file, start_line)
    for i in eachindex(expr.args)
        arg = expr.args[i]
        if arg isa LineNumberNode
            expr.args[i] = modify_lnn(arg; file, start_line)
        elseif arg isa Expr
            modify_lnn!(arg; file, start_line)
        end
    end
end

is_toplevel_funcdef(::FunctionName{N}) where N = N == 1
# This function filters away 
function filter_fnsigs(rn::ReactiveNode, nd::NotebookDefinitions)
    sd = nd.structdefs
    fs = rn.funcdefs_with_signatures
    filter(fs) do (;name)
        is_toplevel_funcdef(name) || return false
        name.joined ∉ sd
    end
end

function extract_funcdefs!(nd::NotebookDefinitions, fnsigs, ex; ss = ScopeState())
    ex isa Expr || return
    if is_function_assignment(ex)
        funcroot = ex.args[1]
        funcname, _ = explore_funcdef!(funcroot, ss)
        fnsig = FunctionNameSignaturePair(funcname, hash(canonalize(funcroot)))
        fnsig ∈ fnsigs || return
        delete!(fnsigs, fnsig)
        push!(nd.funcdefexprs, ex)
    else
        for arg in ex.args
            isempty(fnsigs) && return
            extract_funcdefs!(nd, fnsigs, arg; ss)
        end
    end
end

function process_expanded_expr!(crn::ReactiveNode, notebookdefs::NotebookDefinitions, ex; start_line, caller_data)
    (;filename) = caller_data
    rn = compute_reactive_node(ex)
    # We merge this rn with the compound rn of the notebook
    union!(crn, rn)
    # Find new struct definition, which should have both a method and a definition in the reactive node
    structdefs = intersect(rn.definitions, rn.funcdefs_without_signatures)
    # We add to the stored structdefs
    union!(notebookdefs.structdefs, structdefs)
    # We find the valid function signatures
    fnsigs = filter_fnsigs(rn, notebookdefs)
    !isempty(fnsigs) || return
    # Put the non-pluto line node in this expression
    modify_lnn!(ex; file = filename, start_line)
    extract_funcdefs!(notebookdefs, fnsigs, ex)
    return 
end

function get_modexp(cells_data, caller_data)
    (;pluto_module, cell_uuid) = caller_data
    nd = NotebookDefinitions()
    rn = ReactiveNode()
    for (uuid, start_line, code) in cells_data
        uuid === cell_uuid && break
        eex = Main.PlutoRunner.cell_expanded_exprs[uuid].expanded_expr
        @assert length(eex.args) == 1 && Meta.isexpr(eex.args[1], :block) "The cached expanded exprs should always have a begin end block inside the quote"
        ex = eex.args[1] |> deepcopy
        process_expanded_expr!(rn, nd, ex; start_line, caller_data)
    end
    modex = :(module _NotebookCode_ end)
    toplevel_args = modex.args[end].args
    import_ex = let
        modname_ex = Expr(:., :Main, nameof(pluto_module))
        names_to_import = filter(rn.references) do name
            name ∉ (:eval, :Main) || return false
            contains(String(name), ".") && return false
            name ∈ rn.funcdefs_without_signatures && return false
            return true
        end |> Tuple
        names_exs = map(names_to_import) do name
            Expr(:., name)
        end
        ex = Expr(:(:), modname_ex, names_exs...)
        Expr(:import, ex)
    end
    push!(toplevel_args, import_ex)
    append!(toplevel_args, nd.funcdefexprs)
    modex
end

struct ASD
    b::Int
end

function notebook_code_module(pluto_file_symbol, pluto_module; eval = true)
    filename, cell_uuid = try
        split(String(pluto_file_symbol), "#==#")
    catch e
        @error "It seems you are calling this macro from outside Pluto, which is not supported"
        rethrow()
    end
    filename = String(filename)
    cell_uuid = Base.UUID(cell_uuid)
    file_symbol = Symbol(filename)
    caller_data = (;
        pluto_module,
        cell_uuid,
        pluto_file_symbol,
        filename,
        file_symbol
    )
    cells_data = parse_notebook_cells(filename)
    modex = get_modexp(cells_data, caller_data)
    # We now evaluate this expression in Main
    if eval
        Core.eval(Main, modex)
    end
    modex
end