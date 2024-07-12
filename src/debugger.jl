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
    # 
    notebook_code_module(_file, _mod; eval = true)
    remove_lln!(command)
    try_replace_macros!(command; _mod, _file)
    _names = Set{Symbol}()
    extract_variables!(command; _names, _mod)
    code = if isempty(_names)
        command
    else
        :(let 
            (;$(_names...)) = Main._NotebookCode_
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

const JULIAINTERPRETER_METHODS = (:breakpoints, :enable, :disable, :toggle, :remove)

for f in JULIAINTERPRETER_METHODS
    eval(quote
        function $f(args...)
            I = get_vscode(:JuliaInterpreter)
            I.$f(args...)
        end
    end)
end

#= 
For breakpoint we need to do a custom implementation as it seems only the
file,line signature works. So we always revert to calling that method
=#

"""
    breakpoint(file, line, [condition])

Set a breakpoint in `file` at `line`. The argument `file` can be a filename, a partial path or absolute path.
For example, `file = foo.jl` will match against all files with the name `foo.jl`,
`file = src/foo.jl` will match against all paths containing `src/foo.jl`, e.g. both `Foo/src/foo.jl` and `Bar/src/foo.jl`.
Absolute paths only matches against the file with that exact absolute path.
"""
function breakpoint(file::AbstractString, line::Integer, condition::Condition = nothing)
    I = get_vscode(:JuliaInterpreter)
    I.breakpoint(file, line, condition)
end

"""
    breakpoint(m::Method, [line], [condition])

Add a breakpoint to the file and line specified by method `m`.
Optionally specify an absolute line number `line` in the source file; the default
is to break upon entry at the first line of the body.
Without `condition`, the breakpoint will be triggered every time it is encountered;
the second only if `condition` evaluates to `true`.
`condition` should be written in terms of the arguments and local variables of `m`.

# Example
```julia
function radius2(x, y)
    return x^2 + y^2
end

m = which(radius2, (Int, Int))
breakpoint(m, :(y > x))
```
"""
function breakpoint(m::Method, line::Integer = 0, condition::Condition = nothing)
    file, linem = method_location(m)
    if file === "" && linem == 0
        @info "The provided method is defined in Core, so it has no associated file and no breakpoint can be added to it."
        return
    end
    _line = line == 0 ? linem : line
    breakpoint(file, _line, condition)
end
breakpoint(m::Method, condition::Condition) = breakpoint(m, 0, condition)

