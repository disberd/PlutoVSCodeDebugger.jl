module PlutoVSCodeDebugger

using AbstractPlutoDingetjes
import REPL
import Markdown
import InteractiveUtils

export @run, @enter, @connect_vscode, @vscedit, @bp, @breakpoint

const BASE_DIR = normpath(Sys.BINDIR, Base.DATAROOTDIR, "julia", "base")
const CURRENT_SOCKET = Ref("")

# This is taken from JuliaInterpreter
const Condition = Union{Nothing,Expr,Tuple{Module,Expr}}

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
    for f_name in (PlutoVSCodeDebugger.JULIAINTERPRETER_METHODS..., :breakpoint)
        eval(:(import .PlutoVSCodeDebugger: $f_name))
        eval(:(export $f_name))
    end
end


end


