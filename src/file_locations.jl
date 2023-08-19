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