using PlutoVSCodeDebugger
using PlutoVSCodeDebugger: process_expr, check_pluto
using Test

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
end
