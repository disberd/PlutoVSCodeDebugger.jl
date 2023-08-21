"""
    @connect_vscode begin 
        #=Pasted Code from VSCode=#
    end

This macro is used within a Pluto notebook to connect a VSCode instance running on the same machine as the Pluto Server.

The way to connect the notebook is by following these steps:
- On VSCode, execute the `Julia: Connect external REPL` command and copy the returned code snippet
- Make sure that `PlutoVSCodeDebugger` is loaded in the target Pluto notebook by \
having the `using PlutoVSCodeDebugger` statement inside a cell
- Create a new cell (or modify an existing cell) putting the code copied at \
point 1 inside a `begin - end` block passed to the `@connect_vscode` macro, like \
shown in the call signature at the top of this docstring. 
- Execute the cell containing `@connect_vscode`.

Once the connection is established, you should see a popup in VSCode like the
one below confirming this.

![image](https://github.com/disberd/PlutoVSCodeDebugger.jl/assets/12846528/c60af7a2-2eb6-47a7-973f-1074da41be88)

You can now use [`@enter`](@ref) or [`@run`](@ref) to debug function called in
the notebook workspace exploiting the VSCode debugger.

You can also use the exported [`@vscedit`](@ref) to jump at function definitions
in VSCode from the Pluto notebook for convenience of setting up breakpoints.
This function works similarly to the `@edit` macro from InteractiveUtils.
"""
macro connect_vscode(args...)
    connect_vscode(args...)
end

"""
    @bp

Insert a breakpoint at a location in the source code.
"""
macro bp()
    JuliaInterpreter = get_vscode().JuliaInterpreter
    :($JuliaInterpreter.@bp)
end

"""
    @run command

macro exported by PlutoVSCodeDebugger to allow running the debugger from a Pluto
notebook in a connected VSCode instance.

It works equivalently to the `@run` macro available in the VSCode Julia REPL but
can only be executed after connecting a running VSCode instance with
[`@connect_vscode`](@ref).

## Note
The macro does not currently support debugging commands that contain other macro calls,
except for the `@__FILE__` and `@__MODULE__` ones that are substituted during
macro expansion.

So, when ran with the following example code:
```julia
@run @othermacro args...
```
This macro will simply throw an error because the code to run directly contains another macro.

## Setting breakpoints
Breakpoints set in VSCode will be respected by the `@run` macro, exactly like it would happen in VSCode.
To simplify reaching the file position associated to a given function/method to
put a breakpoint see the [`@vscedit`](@ref) macro also exported by this package.

Functions that are defined inside the notebook directly can only have
breakpoints defined manually either with the [`@breakpoint`](@ref) or
[`@bp`](@ref) macros.
Breakpoints set up on the notebook file using the VSCode GUI will not be hit
because Pluto modifies LineNumberNodes of the notebook functions so that they do
not appear to be originating from the notebook file anymore at runtime.
"""
macro run(command)
    check_pluto() || return nothing
    code = process_expr(command, __module__, __source__.file)
    :($send_to_debugger("debugger/run", code = $(string(code)), filename = $(string(__source__.file))))
end

"""
    @enter command

macro exported by PlutoVSCodeDebugger to allow entering the debugger from a Pluto
notebook in a connected VSCode instance.

It works equivalently to the `@enter` macro available in the VSCode Julia REPL but
can only be executed after connecting a running VSCode instance with
[`@connect_vscode`](@ref).

## Note
The macro does not currently support debugging commands that contain other macro calls,
except for the `@__FILE__` and `@__MODULE__` ones that are substituted during
macro expansion.

So, when ran with the following example code:
```julia
@enter @othermacro args...
```
This macro will simply throw an error because the code to run directly contains another macro.

See also: [`@connect_vscode`](@ref), [`@run`](@ref), [`@vscedit`](@ref)
"""
macro enter(command)
    check_pluto() || return nothing
    code = process_expr(command, __module__, __source__.file)
    :($send_to_debugger("debugger/enter", code = $(string(code)), filename = $(string(__source__.file))))
end

"""
    @vscedit function_name(args...)
    @vscedit function_name
This macro allows opening the file location where the called method of
`function_name` is defined on the VSCode instance connected to the calling Pluto.

The notebook has to be previosuly connected to VSCode using the
[`@connect_vscode`](@ref) macro.

The synthax and functionality of this macro is mirroring the one of the `@edit`
macro available in InteractiveUtils.
When multiple methods for the called signature exists, or when the macro is
called simply with a function name rather than a call signature, the macro will
simply point to the first method on the MethodList return by the `Base.methods`
function.

See also: [`@connect_vscode`](@ref), [`@run`](@ref), [`@enter`](@ref)
"""
macro vscedit(ex)
   vscedit(ex) |> esc
end

# The @breakpoint macro is taken verbatim from JuliaInterpreter, but reverts to the local definition of the `breakpoint` function
"""
    @breakpoint f(args...) condition=nothing
    @breakpoint f(args...) line condition=nothing

Break upon entry, or at the specified line number, in the method called by `f(args...)`.
Optionally supply a condition expressed in terms of the arguments and internal variables
of the method.
If `line` is supplied, it must be a literal integer.

# Example

Suppose a method `mysum` is defined as follows, where the numbers to the left are the line
number in the file:

```
12 function mysum(A)
13     s = zero(eltype(A))
14     for a in A
15         s += a
16     end
17     return s
18 end
```

Then

```
@breakpoint mysum(A) 15 s>10
```

would cause execution of the loop to break whenever `s>10`.
"""
macro breakpoint(call_expr, args...)
    whichexpr = InteractiveUtils.gen_call_with_extracted_types(__module__, :which, call_expr)
    haveline, line, condition = false, 0, nothing
    while !isempty(args)
        arg = first(args)
        if isa(arg, Integer)
            haveline, line = true, arg
        else
            condition = arg
        end
        args = Base.tail(args)
    end
    condexpr = condition === nothing ? nothing : esc(Expr(:quote, condition))
    if haveline
        return quote
            local method = $whichexpr
            $breakpoint(method, $line, $condexpr)
        end
    else
        return quote
            local method = $whichexpr
            $breakpoint(method, $condexpr)
        end
    end
end