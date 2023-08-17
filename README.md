# PlutoVSCodeDebugger

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://disberd.github.io/PlutoVSCodeDebugger.jl/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://disberd.github.io/PlutoVSCodeDebugger.jl/dev)
[![Build Status](https://github.com/disberd/PlutoVSCodeDebugger.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/disberd/PlutoVSCodeDebugger.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/disberd/PlutoVSCodeDebugger.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/disberd/PlutoVSCodeDebugger.jl)

This package provides a very experimental connection between a Pluto Notebook
and the Debugger on a running VSCode instance (the VSCode instance must be
running on the same machine as the Pluto Server)

To connect VSCode to Pluto and exploit the `@run` and `@enter` commands, follow the steps below:
- Copy the julia code to connect an external REPL from your VSCode window by calling the VSCode command `Julia: Connect external REPL`.
- Bring this package into the notebook scope by having a cell with `using PlutoVSCodeDebugger`
- Connect VSCode by calling the `@connect_vscode` macro by giving as an argument a `begin...end` block that contains the code pasted at point 1.

After executing the cell with `@connect_vscode` you should see a popup on VSCode like the one below confirming the successfull connection:

![image](https://github.com/disberd/PlutoVSCodeDebugger.jl/assets/12846528/c60af7a2-2eb6-47a7-973f-1074da41be88)

After succesfull connection you can directly start using the `@enter` and
`@run` macros inside your Pluto notebook.

You can also use the exported @vscedit to jump at function definitions
in VSCode from the Pluto notebook for convenience of setting up breakpoints.
This function works similarly to the `@edit` macro from InteractiveUtils.

## Note
The current code is not very convenient to debug code functions that are defined
within the notebook, simply because it's not possible to put breakpoints inside
of those function. It is still possible to use `@enter` and then step in/through
the lines but it might be tedious to reach deeply nested functions in this way.

For what concerns code that is imported in the notebook either from other
packages or by including files, breakpoints can be added on VSCode and are
reached correctly when using the `@run` or `@enter` macro.

## Examples

### Connecting VSCode
https://github.com/disberd/PlutoVSCodeDebugger.jl/assets/12846528/02341cfb-9d89-4528-96dc-ebac3f05b0d6

### Debugging code of imported Package
https://github.com/disberd/PlutoVSCodeDebugger.jl/assets/12846528/9b1af23f-dfe1-4a4b-b7e2-b1092c36be99

### Debugging code of directly included files
https://github.com/disberd/PlutoVSCodeDebugger.jl/assets/12846528/4da1a4ed-38cd-4f41-a5e2-6fef5f68280a

### Debugging code defined in notebook
https://github.com/disberd/PlutoVSCodeDebugger.jl/assets/12846528/12443203-0415-4269-8117-5dfa98169a9d



