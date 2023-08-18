clean_err(msg) = error(replace(msg, r"\n[\t ]+" => "\n")) # Remove whitespace after newline

check_pluto() = is_inside_pluto() || (@warn("This package is only intended for use inside of a Pluto notebook, ignoring this command"); false)
get_vscode() = if isdefined(Main, :VSCodeServer) 
    Main.VSCodeServer 
else 
    clean_err("It seems like VSCodeServer has not been loaded in this notebook.
    Remember to hook VSCode to this notebook by calling the `@connect_vscode` macro.")
end

# Write your package code here.
extract_variables!(s::Symbol; _names, _mod) = isdefined(_mod, s) && !isdefined(Main, s) && !isdefined(Base, s) && push!(_names, s)
extract_variables!(x; kwargs...) = nothing
function extract_variables!(ex::Expr; kwargs...)
    if ex.head === :.
        extract_variables!(ex.args |> first; kwargs...)
    else
        foreach(x -> extract_variables!(x; kwargs...), ex.args)
    end
    return nothing
end

remove_problematic_macros!(x; kwargs...) = nothing
function remove_problematic_macros!(ex::Expr; wrapped = false, _mod, _file)
    if !wrapped 
        # We wrap the first expression as we only process the args
        nex = remove_problematic_macros!(Expr(:wrapped, ex); wrapped = true, _mod, _file)
        return first(nex.args)
    end
    args = ex.args
    for i in eachindex(args)
        arg = args[i]
        if !Meta.isexpr(arg, :macrocall) 
            remove_problematic_macros!(arg; wrapped, _mod, _file)
            continue
        end
        macro_name = arg.args[1] |> string
        if macro_name === "@__FILE__"
            s = string(_file)
            fn = split(s, "#==#") |> first
            args[i] = string(fn)
        elseif macro_name === "@__MODULE__"
            args[i] = _mod
        else
            clean_err("Running the debugger on code containing a macro is currently not supported.
            It hangs the debugger before it starts, requiring a reload of VSCode and a reconnection with the notebook.")
            # remove_problematic_macros!(arg; _mod, _file)
        end
    end
    return ex
end

# This is taken from VSCodeServer
function remove_lln!(ex::Expr)
    for i = length(ex.args):-1:1
        if ex.args[i] isa LineNumberNode
            deleteat!(ex.args, i)
        elseif ex.args[i] isa Expr
            remove_lln!(ex.args[i])
        end
    end
end

function process_expr(command, _mod, _file)
    remove_lln!(command)
    remove_problematic_macros!(command; _mod, _file)
    _names = Set{Symbol}()
    extract_variables!(command; _names, _mod)
    code = if isempty(_names)
        command
    else
        :(let 
            (;$(_names...)) = $_mod
            $command
        end)
    end
    remove_lln!(code)
    code
end

# Open File
function method_location(m::Method)
    file = string(m.file)
    path = m.module === Base ? joinpath(BASE_DIR, file) : file
    return path, Int(m.line)
end

function open_file_vscode(path::String, line::Int)
    VSCodeServer = get_vscode()
    (; JSONRPC, conn_endpoint, repl_open_file_notification_type) = VSCodeServer
    JSONRPC.send(conn_endpoint[], repl_open_file_notification_type, (; path, line))
    nothing
end
function open_file_vscode(m::Method)
    if m.module === Core
        @info "The method `$(m.name)` is defined in Core, so it has no associated file."
        return
    end
    path, line = method_location(m)
    open_file_vscode(path, line)
end
open_file_vscode(v::Base.MethodList) = open_file_vscode(first(v))
open_file_vscode(f::Function) = open_file_vscode(methods(f))
open_file_vscode(x) = error("The provided type $(typeof(x)) is not a valid input for `open_file_vscode`")

function send_to_debugger(method; code, filename)
    VSCodeServer = get_vscode()
    (; JSONRPC, conn_endpoint) = VSCodeServer
    JSONRPC.send_notification(conn_endpoint[], method, (; code, filename))
end

function vscedit(ex::Expr)
    head = ex.head
    open_args = if head === :call
        fname, fargs... = ex.args
        :(methods($fname, typeof.(($(fargs...),))))
    elseif head === :macrocall
        mname, ln, margs... = ex.args
        types = (LineNumberNode, Module, typeof.(margs)...)
        :(methods($mname, $types))
    elseif head === :.
        :($ex)
    else
        error("You have to provide a function call to the `@vscedit` macro.")
    end
    :($open_file_vscode($open_args))
end
vscedit(fname::Symbol) = :($open_file_vscode($fname))