module PlutoVSCodeDebugger

using AbstractPlutoDingetjes
import REPL
import Markdown

export @run, @enter, @connect_vscode, @vscedit, @bp
export breakpoint, breakpoints, remove

const BASE_DIR = normpath(Sys.BINDIR, Base.DATAROOTDIR, "julia", "base")

include("basics.jl")
include("file_locations.jl")
include("debugger.jl")
include("macros.jl")

end


