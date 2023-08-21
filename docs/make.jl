using PlutoVSCodeDebugger
using Documenter
import JuliaInterpreter

DocMeta.setdocmeta!(PlutoVSCodeDebugger, :DocTestSetup, :(using PlutoVSCodeDebugger); recursive=true)

makedocs(;
    modules=[PlutoVSCodeDebugger, JuliaInterpreter],
    authors="Alberto Mengali <disberd@gmail.com>",
    repo="https://github.com/disberd/PlutoVSCodeDebugger.jl/blob/{commit}{path}#{line}",
    sitename="PlutoVSCodeDebugger.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Quick Start" => "examples.md",
        "Exported Functions" => "public_api.md",
    ],
)

# This controls whether or not deployment is attempted. It is based on the value
# of the `SHOULD_DEPLOY` ENV variable, which defaults to the `CI` ENV variables or
# false if not present.
should_deploy = get(ENV,"SHOULD_DEPLOY", get(ENV, "CI", "") === "true")

if should_deploy
    @info "Deploying"

deploydocs(
    repo = "github.com/disberd/PlutoVSCodeDebugger.jl.git",
)

end