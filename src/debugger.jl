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

try_replace_macros!(x; kwargs...) = nothing
function try_replace_macros!(ex::Expr; wrapped = false, _mod, _file)
    if !wrapped 
        # We wrap the first expression as we only process the args
        nex = try_replace_macros!(Expr(:wrapped, ex); wrapped = true, _mod, _file)
        return first(nex.args)
    end
    args = ex.args
    for i in eachindex(args)
        arg = args[i]
        if !Meta.isexpr(arg, :macrocall) 
            try_replace_macros!(arg; wrapped, _mod, _file)
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
            It hangs the debugger before it starts, requiring a reload of VSCode and a reconnection with the notebook.
            See https://github.com/julia-vscode/julia-vscode/issues/2710 for the relevant issue in VSCode")
            # try_replace_macros!(arg; _mod, _file)
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
    try_replace_macros!(command; _mod, _file)
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

function send_to_debugger(method; code, filename)
    VSCodeServer = get_vscode()
    (; JSONRPC, conn_endpoint) = VSCodeServer
    JSONRPC.send_notification(conn_endpoint[], method, (; code, filename))
end

## JuliaInterpreter methods

const JULIAINTERPRETER_METHODS = (:breakpoint, :breakpoints, :enable, :disable, :toggle, :remove)

for f in JULIAINTERPRETER_METHODS
    eval(quote
        export $f
        function $f(args...)
            I = get_vscode(:JuliaInterpreter)
            I.$f(args...)
        end
    end)
end