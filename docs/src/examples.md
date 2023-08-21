# Quick Start
Here are a few example videos showing how to set up and use PlutoVSCodeDebugger for debugging

## Connecting to VSCode
Connecting to a running vscode instance is done via the [`@connect_vscode`](@ref) macro. The macro expects a single begin-end block containing the connection command copied from VSCode.

When executed with no argument, the macro will simply modify its cell to include the begin-end block for convenience.
```@raw html
<video controls=true>
<source src="https://github.com/disberd/PlutoVSCodeDebugger.jl/assets/12846528/8ba2b2e6-9254-40b9-b7d5-e91f3a018738" type="video/mp4">
</video>
```

## Debug Package Code
To debug code defined inside a package loaded within Pluto the workflow is very straightforward. One sets breakpoints in the connected VSCode and those are hit when using the [`@run`](@ref) macro.

To simplify opening up the desired file location associated to a method or function, one can use the [`@vscedit`](@ref) macro directly from the notebook. This will open the file location associated to the provided function or method in the connected VSCode instance.

The synthax of [`@vscedit`](@ref) is very similar to `@edit` from InteractiveUtils, but check the docstrings for more information.
```@raw html
<video controls=true>
<source src="https://github.com/disberd/PlutoVSCodeDebugger.jl/assets/12846528/0c0628fe-55ce-4acb-90a1-56fcb48241f6" type="video/mp4">
</video>
```

## Debug Included Code
Debugging code that is directly included in the notebook with `include` also works equivalently to code defined inside a package.
```@raw html
<video controls=true>
<source src="https://github.com/disberd/PlutoVSCodeDebugger.jl/assets/12846528/0794ec45-d78c-42a6-9e0e-906a5a087c66" type="video/mp4">
</video>
```

## Debug Notebook Code
Debugging code defined inside the notebook can not be done by adding breakpoint markers in the notebook file in VSCode.

This is because Pluto internally modifies the LineNumbers of expression associated to the notebook code so a breakpoint added on the notebook file on VSCode will not be triggered when executing code from Pluto.

While not as convenient as setting breakpoints using the VSCode UI, one can still manually set breakpoint either by inserting the [`@bp`](@ref) macro in function definitions or by using the [`@breakpoint`](@ref) macro with a call signature.
```@raw html
<video controls=true>
<source src="https://github.com/disberd/PlutoVSCodeDebugger.jl/assets/12846528/c9864d8d-0605-4d84-9724-1b38e1855830" type="video/mp4">
</video>
```