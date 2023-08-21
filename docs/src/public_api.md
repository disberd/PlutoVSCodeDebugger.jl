# Exported Functions
This package exports a set of convenience macros that mostly mirror the debugging macros found in `JuliaInterpreter`.

Two additional macros, [`@connect_vscode`](@ref) and [`@vscedit`](@ref), provide helpful functionality to connect to and open files inside the connected VSCode Instance

## Macros
### VSCode interaction
```@docs
@connect_vscode
@vscedit
```
### Debugging Code
```@docs
@run
@enter
```
### Adding Breakpoints Manually
```@docs
@breakpoint
@bp
```

## Functions
The PlutoVSCodeServer does not export any function but only macros. It is possible to also exports the debugging-related functions from `JuliaInterpreter` to add/remove or modify breakpoints manually. 

To do so, one can use the submodule `PlutoVSCodeServer.WithFunctions` like so:
```julia
using PlutoVSCodeServer.WithFunctions
```
The `WithFunctions` submodule will *re-export* `PlutoVSCodeServer` plus all the breakpoint manipulation functions listed below.

!!! note
    This package will simply forward these methods to the corresponding ones present in the `JuliaInterpreter` module loaded by the `VSCodeServer` package in the vscode-julia extensions.\
    \
    The only slight modification comes to the [`PlutoVSCodeDebugger.breakpoint`](@ref) function which only works in Pluto when called directly with a file and line-number, as opposed as when called with a function or method.\
    \
    The remaining docstrings are simply taken from the ones from InteractiveUtils.
```@docs
PlutoVSCodeDebugger.breakpoint
JuliaInterpreter.breakpoints
JuliaInterpreter.enable
JuliaInterpreter.disable
JuliaInterpreter.toggle
JuliaInterpreter.remove
```