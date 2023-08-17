using PlutoVSCodeDebugger
using PlutoVSCodeDebugger: process_expr, check_pluto, send_to_debugger, open_file_vscode, method_location, vscedit, get_vscode, clean_err
using Test


@testset "PlutoVSCodeDebugger.jl" begin
    @test_throws "has not been loaded" get_vscode()

    Base.eval(Main, :(module VSCodeServer
        module JSONRPC
            send(args...) = nothing
            send_notification(args...) = nothing
        end
        conn_endpoint = Ref(nothing)
        repl_open_file_notification_type = nothing
    end))

    @test get_vscode() === Main.VSCodeServer

    file = @__FILE__
    ex = :(my_func(@__FILE__))
    s = string(process_expr(ex, @__MODULE__, file))
    @test !contains(s, "@__FILE__")
    @test contains(s, file)

    ex = :(my_func(@__MODULE__))
    s = string(process_expr(ex, @__MODULE__, file))
    @test !contains(s, "@__MODULE__")
    @test contains(s, string(@__MODULE__))

    ex = :(@asd 3+2)
    @test_throws "macro is currently not supported" process_expr(ex, @__MODULE__, file)
    
    @test_logs (:warn, r"ignoring this command") check_pluto()

    mets = methods(+)
    m = first(mets)
    @test send_to_debugger(m; code = "3+2", filename = "asd") === nothing
    @test open_file_vscode(mets) === nothing

    @test_logs (:info, r"is defined in Core") open_file_vscode(getfield)
    @test_throws "$(typeof(3)) is not a valid input" open_file_vscode(3)

    @test method_location(first(methods(getfield))) === ("", 0) # This is in Core so it has no file/line

    @test vscedit(:s) == :($open_file_vscode(s))
    fcalltest = :(asd(3))
    @test vscedit(fcalltest) == :($open_file_vscode(methods(asd, typeof.($(fcalltest.args[2:end])))))
    mcalltest = :(@asd(3))
    @test vscedit(mcalltest) == :($open_file_vscode(methods($(mcalltest.args[1]), $((LineNumberNode, Module, typeof(mcalltest.args[end]))))))
    fnametest = :(VSCodeServer.JSONRPC.send_notification)
    @test vscedit(fnametest) == :($open_file_vscode($fnametest))

end
