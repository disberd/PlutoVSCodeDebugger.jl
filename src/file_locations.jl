function method_location(m::Method)
    file = string(m.file)
    path = m.module === Base ? joinpath(BASE_DIR, file) : file
    return path, Int(m.line)
end
method_location(m::Base.MethodList) = map(method_location, m)
method_location(f::Function) = method_location(methods(f))

function open_file_vscode(path::String, line::Int)
    if path === "" && line == 0
        @info "The method `$(m.name)` is defined in Core, so it has no associated file."
        return
    end
    VSCodeServer = get_vscode()
    (; JSONRPC, conn_endpoint, repl_open_file_notification_type) = VSCodeServer
    JSONRPC.send(conn_endpoint[], repl_open_file_notification_type, (; path, line))
    nothing
end
open_file_vscode(m::Method) = open_file_vscode(method_location(m))
open_file_vscode(ml_or_f::Union{Base.MethodList, Function}) = open_file_vscode(first(method_location(ml_or_f))...)
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