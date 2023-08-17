module PlutoVSCodeDebugger

using AbstractPlutoDingetjes


export @run, @enter, @connect_vscode, @vscedit

const BASE_DIR = normpath(Sys.BINDIR, Base.DATAROOTDIR, "julia", "base")

include("functions.jl")
include("macros.jl")

end


