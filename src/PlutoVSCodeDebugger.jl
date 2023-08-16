module PlutoVSCodeDebugger

using AbstractPlutoDingetjes


export @run, @enter, @connect_vscode, @vscedit

const BASE_DIR = normpath(Sys.BINDIR, Base.DATAROOTDIR, "julia", "base")

check_pluto() = is_inside_pluto() || (@warn("This package is only intended for use inside of a Pluto notebook, ignoring this command"); false)
get_vscode() = if isdefined(Main, :VSCodeServer) 
    Main.VSCodeServer 
else 
    error("It seems like VSCodeServer has not been loaded in this notebook.
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
function remove_problematic_macros!(ex::Expr; _mod, _file)
    args = ex.args
    for i in eachindex(args)
        arg = args[i]
        if !Meta.isexpr(arg, :macrocall) 
            remove_problematic_macros!(arg; _mod, _file)
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
            remove_problematic_macros!(arg; _mod, _file)
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

function send_to_debugger(method; code, filename)
    VSCodeServer = get_vscode()
    (; JSONRPC, conn_endpoint) = VSCodeServer
    JSONRPC.send_notification(conn_endpoint[], method, (; code, filename))
end

macro connect_vscode(block)
    check_pluto() || return nothing
    Meta.isexpr(block, (:block)) || error("Please wrap the code copied from VSCode into a begin-end block.
You have to provide the VSCode External REPL command surrounded by a begin-end block to avoid macro parsing problems.")
    # We execute the command in Main
    Base.eval(Main, block)
    "VSCode succesfully connected"
end

macro run(command)
    check_pluto() || return nothing
    code = process_expr(command, __module__, __source__.file)
    :($send_to_debugger("debugger/run", code = $(string(code)), filename = $(string(__source__.file))))
end

macro enter(command)
    check_pluto() || return nothing
    code = process_expr(command, __module__, __source__.file)
    :($send_to_debugger("debugger/enter", code = $(string(code)), filename = $(string(__source__.file))))
end

macro vscedit(funcall::Expr)
    head = funcall.head
    if head === :call
        fname, fargs... = funcall.args
        :($open_file_vscode(methods($fname, typeof.($fargs)))) |> esc
    elseif head === :macrocall
        mname, ln, margs... = funcall.args
        types = (LineNumberNode, Module, typeof.(margs)...)
        :($open_file_vscode(methods($mname, $types))) |> esc
    else
        error("You have to provide a function call to the `@vscedit` macro.")
    end
end

end


