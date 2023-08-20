module PlutoVSCodeDebugger

using AbstractPlutoDingetjes
import REPL
import Markdown

export @run, @enter, @connect_vscode, @vscedit, @bp

const BASE_DIR = normpath(Sys.BINDIR, Base.DATAROOTDIR, "julia", "base")

include("basics.jl")
include("file_locations.jl")
include("debugger.jl")
include("macros.jl")

# This module just re-export the main module plus the debgging functions of JuliaInterpreter
module WithFunctions
    using ..PlutoVSCodeDebugger
    # Re-Export PlutoVSCodeDebugger
    eval(:(export $(names(PlutoVSCodeDebugger)...)))
    # Import and re-export the JuliaInterpreter functions
    for f_name in PlutoVSCodeDebugger.JULIAINTERPRETER_METHODS
        eval(:(import .PlutoVSCodeDebugger: $f_name))
        eval(:(export $f_name))
    end
end


end


