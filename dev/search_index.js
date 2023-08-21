var documenterSearchIndex = {"docs":
[{"location":"public_api/#Exported-Functions","page":"Exported Functions","title":"Exported Functions","text":"","category":"section"},{"location":"public_api/","page":"Exported Functions","title":"Exported Functions","text":"This package exports a set of convenience macros that mostly mirror the debugging macros found in JuliaInterpreter.","category":"page"},{"location":"public_api/","page":"Exported Functions","title":"Exported Functions","text":"Two additional macros, @connect_vscode and @vscedit, provide helpful functionality to connect to and open files inside the connected VSCode Instance","category":"page"},{"location":"public_api/#Macros","page":"Exported Functions","title":"Macros","text":"","category":"section"},{"location":"public_api/#VSCode-interaction","page":"Exported Functions","title":"VSCode interaction","text":"","category":"section"},{"location":"public_api/","page":"Exported Functions","title":"Exported Functions","text":"@connect_vscode\n@vscedit","category":"page"},{"location":"public_api/#PlutoVSCodeDebugger.@connect_vscode","page":"Exported Functions","title":"PlutoVSCodeDebugger.@connect_vscode","text":"@connect_vscode begin \n    #=Pasted Code from VSCode=#\nend\n\nThis macro is used within a Pluto notebook to connect a VSCode instance running on the same machine as the Pluto Server.\n\nThe way to connect the notebook is by following these steps:\n\nOn VSCode, execute the Julia: Connect external REPL command and copy the returned code snippet\nMake sure that PlutoVSCodeDebugger is loaded in the target Pluto notebook by having the using PlutoVSCodeDebugger statement inside a cell\nCreate a new cell (or modify an existing cell) putting the code copied at point 1 inside a begin - end block passed to the @connect_vscode macro, like shown in the call signature at the top of this docstring. \nExecute the cell containing @connect_vscode.\n\nOnce the connection is established, you should see a popup in VSCode like the one below confirming this.\n\n(Image: image)\n\nYou can now use @enter or @run to debug function called in the notebook workspace exploiting the VSCode debugger.\n\nYou can also use the exported @vscedit to jump at function definitions in VSCode from the Pluto notebook for convenience of setting up breakpoints. This function works similarly to the @edit macro from InteractiveUtils.\n\n\n\n\n\n","category":"macro"},{"location":"public_api/#PlutoVSCodeDebugger.@vscedit","page":"Exported Functions","title":"PlutoVSCodeDebugger.@vscedit","text":"@vscedit function_name(args...)\n@vscedit function_name\n\nThis macro allows opening the file location where the called method of function_name is defined on the VSCode instance connected to the calling Pluto.\n\nThe notebook has to be previosuly connected to VSCode using the @connect_vscode macro.\n\nThe synthax and functionality of this macro is mirroring the one of the @edit macro available in InteractiveUtils. When multiple methods for the called signature exists, or when the macro is called simply with a function name rather than a call signature, the macro will simply point to the first method on the MethodList return by the Base.methods function.\n\nSee also: @connect_vscode, @run, @enter\n\n\n\n\n\n","category":"macro"},{"location":"public_api/#Debugging-Code","page":"Exported Functions","title":"Debugging Code","text":"","category":"section"},{"location":"public_api/","page":"Exported Functions","title":"Exported Functions","text":"@run\n@enter","category":"page"},{"location":"public_api/#PlutoVSCodeDebugger.@run","page":"Exported Functions","title":"PlutoVSCodeDebugger.@run","text":"@run command\n\nmacro exported by PlutoVSCodeDebugger to allow running the debugger from a Pluto notebook in a connected VSCode instance.\n\nIt works equivalently to the @run macro available in the VSCode Julia REPL but can only be executed after connecting a running VSCode instance with @connect_vscode.\n\nNote\n\nThe macro does not currently support debugging commands that contain other macro calls, except for the @__FILE__ and @__MODULE__ ones that are substituted during macro expansion.\n\nSo, when ran with the following example code:\n\n@run @othermacro args...\n\nThis macro will simply throw an error because the code to run directly contains another macro.\n\nSetting breakpoints\n\nBreakpoints set in VSCode will be respected by the @run macro, exactly like it would happen in VSCode. To simplify reaching the file position associated to a given function/method to put a breakpoint see the @vscedit macro also exported by this package.\n\nFunctions that are defined inside the notebook directly can only have breakpoints defined manually either with the @breakpoint or @bp macros. Breakpoints set up on the notebook file using the VSCode GUI will not be hit because Pluto modifies LineNumberNodes of the notebook functions so that they do not appear to be originating from the notebook file anymore at runtime.\n\n\n\n\n\n","category":"macro"},{"location":"public_api/#PlutoVSCodeDebugger.@enter","page":"Exported Functions","title":"PlutoVSCodeDebugger.@enter","text":"@enter command\n\nmacro exported by PlutoVSCodeDebugger to allow entering the debugger from a Pluto notebook in a connected VSCode instance.\n\nIt works equivalently to the @enter macro available in the VSCode Julia REPL but can only be executed after connecting a running VSCode instance with @connect_vscode.\n\nNote\n\nThe macro does not currently support debugging commands that contain other macro calls, except for the @__FILE__ and @__MODULE__ ones that are substituted during macro expansion.\n\nSo, when ran with the following example code:\n\n@enter @othermacro args...\n\nThis macro will simply throw an error because the code to run directly contains another macro.\n\nSee also: @connect_vscode, @run, @vscedit\n\n\n\n\n\n","category":"macro"},{"location":"public_api/#Adding-Breakpoints-Manually","page":"Exported Functions","title":"Adding Breakpoints Manually","text":"","category":"section"},{"location":"public_api/","page":"Exported Functions","title":"Exported Functions","text":"@breakpoint\n@bp","category":"page"},{"location":"public_api/#PlutoVSCodeDebugger.@breakpoint","page":"Exported Functions","title":"PlutoVSCodeDebugger.@breakpoint","text":"@breakpoint f(args...) condition=nothing\n@breakpoint f(args...) line condition=nothing\n\nBreak upon entry, or at the specified line number, in the method called by f(args...). Optionally supply a condition expressed in terms of the arguments and internal variables of the method. If line is supplied, it must be a literal integer.\n\nExample\n\nSuppose a method mysum is defined as follows, where the numbers to the left are the line number in the file:\n\n12 function mysum(A)\n13     s = zero(eltype(A))\n14     for a in A\n15         s += a\n16     end\n17     return s\n18 end\n\nThen\n\n@breakpoint mysum(A) 15 s>10\n\nwould cause execution of the loop to break whenever s>10.\n\n\n\n\n\n","category":"macro"},{"location":"public_api/#PlutoVSCodeDebugger.@bp","page":"Exported Functions","title":"PlutoVSCodeDebugger.@bp","text":"@bp\n\nInsert a breakpoint at a location in the source code.\n\n\n\n\n\n","category":"macro"},{"location":"public_api/#Functions","page":"Exported Functions","title":"Functions","text":"","category":"section"},{"location":"public_api/","page":"Exported Functions","title":"Exported Functions","text":"The PlutoVSCodeServer does not export any function but only macros. It is possible to also exports the debugging-related functions from JuliaInterpreter to add/remove or modify breakpoints manually. ","category":"page"},{"location":"public_api/","page":"Exported Functions","title":"Exported Functions","text":"To do so, one can use the submodule PlutoVSCodeServer.WithFunctions like so:","category":"page"},{"location":"public_api/","page":"Exported Functions","title":"Exported Functions","text":"using PlutoVSCodeServer.WithFunctions","category":"page"},{"location":"public_api/","page":"Exported Functions","title":"Exported Functions","text":"The WithFunctions submodule will re-export PlutoVSCodeServer plus all the breakpoint manipulation functions listed below.","category":"page"},{"location":"public_api/","page":"Exported Functions","title":"Exported Functions","text":"note: Note\nThis package will simply forward these methods to the corresponding ones present in the JuliaInterpreter module loaded by the VSCodeServer package in the vscode-julia extensions.\n\nThe only slight modification comes to the PlutoVSCodeDebugger.breakpoint function which only works in Pluto when called directly with a file and line-number, as opposed as when called with a function or method.\n\nThe remaining docstrings are simply taken from the ones from InteractiveUtils.","category":"page"},{"location":"public_api/","page":"Exported Functions","title":"Exported Functions","text":"PlutoVSCodeDebugger.breakpoint\nJuliaInterpreter.breakpoints\nJuliaInterpreter.enable\nJuliaInterpreter.disable\nJuliaInterpreter.toggle\nJuliaInterpreter.remove","category":"page"},{"location":"public_api/#PlutoVSCodeDebugger.breakpoint","page":"Exported Functions","title":"PlutoVSCodeDebugger.breakpoint","text":"breakpoint(file, line, [condition])\n\nSet a breakpoint in file at line. The argument file can be a filename, a partial path or absolute path. For example, file = foo.jl will match against all files with the name foo.jl, file = src/foo.jl will match against all paths containing src/foo.jl, e.g. both Foo/src/foo.jl and Bar/src/foo.jl. Absolute paths only matches against the file with that exact absolute path.\n\n\n\n\n\nbreakpoint(m::Method, [line], [condition])\n\nAdd a breakpoint to the file and line specified by method m. Optionally specify an absolute line number line in the source file; the default is to break upon entry at the first line of the body. Without condition, the breakpoint will be triggered every time it is encountered; the second only if condition evaluates to true. condition should be written in terms of the arguments and local variables of m.\n\nExample\n\nfunction radius2(x, y)\n    return x^2 + y^2\nend\n\nm = which(radius2, (Int, Int))\nbreakpoint(m, :(y > x))\n\n\n\n\n\n","category":"function"},{"location":"public_api/#JuliaInterpreter.breakpoints","page":"Exported Functions","title":"JuliaInterpreter.breakpoints","text":"breakpoints()::Vector{AbstractBreakpoint}\n\nReturn an array with all breakpoints.\n\n\n\n\n\n","category":"function"},{"location":"public_api/#JuliaInterpreter.enable","page":"Exported Functions","title":"JuliaInterpreter.enable","text":"enable(bp::AbstractBreakpoint)\n\nEnable breakpoint bp.\n\n\n\n\n\nenable()\n\nEnable all breakpoints.\n\n\n\n\n\n","category":"function"},{"location":"public_api/#JuliaInterpreter.disable","page":"Exported Functions","title":"JuliaInterpreter.disable","text":"disable(bp::AbstractBreakpoint)\n\nDisable breakpoint bp. Disabled breakpoints can be re-enabled with enable.\n\n\n\n\n\ndisable()\n\nDisable all breakpoints.\n\n\n\n\n\n","category":"function"},{"location":"public_api/#JuliaInterpreter.toggle","page":"Exported Functions","title":"JuliaInterpreter.toggle","text":"toggle(bp::AbstractBreakpoint)\n\nToggle breakpoint bp.\n\n\n\n\n\n","category":"function"},{"location":"public_api/#JuliaInterpreter.remove","page":"Exported Functions","title":"JuliaInterpreter.remove","text":"remove(bp::AbstractBreakpoint)\n\nRemove (delete) breakpoint bp. Removed breakpoints cannot be re-enabled.\n\n\n\n\n\nremove()\n\nRemove all breakpoints.\n\n\n\n\n\n","category":"function"},{"location":"examples/#Quick-Start","page":"Quick Start","title":"Quick Start","text":"","category":"section"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"Here are a few example videos showing how to set up and use PlutoVSCodeDebugger for debugging. ","category":"page"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"All of the videos below are recording of code execution from the example notebook found at examples/test_notebook.jl","category":"page"},{"location":"examples/#Connecting-to-VSCode","page":"Quick Start","title":"Connecting to VSCode","text":"","category":"section"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"Connecting to a running vscode instance is done via the @connect_vscode macro. The macro expects a single begin-end block containing the connection command copied from VSCode.","category":"page"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"When executed with no argument, the macro will simply modify its cell to include the begin-end block for convenience.","category":"page"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"<video controls=true>\n<source src=\"https://github.com/disberd/PlutoVSCodeDebugger.jl/assets/12846528/8ba2b2e6-9254-40b9-b7d5-e91f3a018738\" type=\"video/mp4\">\n</video>","category":"page"},{"location":"examples/#Debug-Package-Code","page":"Quick Start","title":"Debug Package Code","text":"","category":"section"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"To debug code defined inside a package loaded within Pluto the workflow is very straightforward. One sets breakpoints in the connected VSCode and those are hit when using the @run macro.","category":"page"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"To simplify opening up the desired file location associated to a method or function, one can use the @vscedit macro directly from the notebook. This will open the file location associated to the provided function or method in the connected VSCode instance.","category":"page"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"The synthax of @vscedit is very similar to @edit from InteractiveUtils, but check the docstrings for more information.","category":"page"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"<video controls=true>\n<source src=\"https://github.com/disberd/PlutoVSCodeDebugger.jl/assets/12846528/0c0628fe-55ce-4acb-90a1-56fcb48241f6\" type=\"video/mp4\">\n</video>","category":"page"},{"location":"examples/#Debug-Included-Code","page":"Quick Start","title":"Debug Included Code","text":"","category":"section"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"Debugging code that is directly included in the notebook with include also works equivalently to code defined inside a package.","category":"page"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"<video controls=true>\n<source src=\"https://github.com/disberd/PlutoVSCodeDebugger.jl/assets/12846528/0794ec45-d78c-42a6-9e0e-906a5a087c66\" type=\"video/mp4\">\n</video>","category":"page"},{"location":"examples/#Debug-Notebook-Code","page":"Quick Start","title":"Debug Notebook Code","text":"","category":"section"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"Debugging code defined inside the notebook can not be done by adding breakpoint markers in the notebook file in VSCode.","category":"page"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"This is because Pluto internally modifies the LineNumbers of expression associated to the notebook code so a breakpoint added on the notebook file on VSCode will not be triggered when executing code from Pluto.","category":"page"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"While not as convenient as setting breakpoints using the VSCode UI, one can still manually set breakpoint either by inserting the @bp macro in function definitions or by using the @breakpoint macro with a call signature.","category":"page"},{"location":"examples/","page":"Quick Start","title":"Quick Start","text":"<video controls=true>\n<source src=\"https://github.com/disberd/PlutoVSCodeDebugger.jl/assets/12846528/c9864d8d-0605-4d84-9724-1b38e1855830\" type=\"video/mp4\">\n</video>","category":"page"},{"location":"#PlutoVSCodeDebugger","page":"Home","title":"PlutoVSCodeDebugger","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for PlutoVSCodeDebugger.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This package provides convenience functions and macros to connect an active VSCode instance to a running Pluto notebook mostly for debugging purposes.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Once connected, the exported macros (mostly mirrored from the ones in JuliaInterpreter) can be used to start debugging code from the Pluto workspace using the VSCode debugging interface.","category":"page"},{"location":"#Contents","page":"Home","title":"Contents","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Pages = [\"examples.md\", \"public_api.md\"]","category":"page"}]
}
