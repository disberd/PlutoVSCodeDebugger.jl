using PlutoVSCodeDebugger
using PlutoVSCodeDebugger: process_expr, check_pluto, send_to_debugger, open_file_vscode
using Test

module VSCodeServer
    module JSONRPC
        send(args...) = nothing
        send_notification(args...) = nothing
    end
    conn_endpoint = Ref(nothing)
    repl_open_file_notification_type = nothing
end

@testset "PlutoVSCodeDebugger.jl" begin
    file = @__FILE__
    ex = :(my_func(@__FILE__))
    s = string(process_expr(ex, @__MODULE__, file))
    @test !contains(s, "@__FILE__")
    @test contains(s, file)

    ex = :(my_func(@__MODULE__))
    s = string(process_expr(ex, @__MODULE__, file))
    @test !contains(s, "@__MODULE__")
    @test contains(s, string(@__MODULE__))
    
    @test_logs (:warn, r"ignoring this command") check_pluto()

    mets = methods(+)
    m = first(mets)
    @test send_to_debugger(m; code = "3+2", filename = "asd") === nothing
    @test open_file_vscode(mets) === nothing
end
