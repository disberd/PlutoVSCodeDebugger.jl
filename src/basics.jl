clean_err(msg) = error(replace(msg, r"\n[\t ]+" => "\n")) # Remove whitespace after newline

check_pluto() = is_inside_pluto() || (@warn("This package is only intended for use inside of a Pluto notebook, ignoring this command"); false)

has_vscode() = isdefined(Main, :VSCodeServer)
get_vscode(; throw_on_closed = true) = if has_vscode() 
    V = Main.VSCodeServer 
    if throw_on_closed && !isopen(V.conn_endpoint[])
        clean_err("VSCodeServer is loaded as a Module but it does not have an open connection to a running VSCode instance.
        Consider re-doing the connection procedure with a newly obtained connection code from VSCode")
    end
    V
else 
    clean_err("It seems like VSCodeServer has not been loaded in this notebook.
    Remember to hook VSCode to this notebook by calling the `@connect_vscode` macro.")
end
get_vscode(s::Symbol; kwargs...) = getfield(get_vscode(;kwargs...), s)

function maybe_clean_vscode_module(; close_endpoint = true)
    # We empty the list of breakpoints and breakpoints hooks
    try
        V = get_vscode(; throw_on_closed = false)
        endpoint = V.conn_endpoint[]
        if close_endpoint
            close(endpoint)
        else
            # Only clear if the endpoint is already closed
            isopen(endpoint) && return nothing
        end
        JI = V.JuliaInterpreter
        empty!(JI._breakpoints)
        empty!(JI.breakpoint_update_hooks)
        nothing
    catch
    end
end

function connect_vscode(block; skip_pluto_check = false)
    skip_pluto_check || check_pluto() || return nothing
    Meta.isexpr(block, (:block)) || clean_err("Please wrap the code copied from VSCode into a begin-end block.
    You have to provide the VSCode External REPL command surrounded by a begin-end block to avoid macro parsing problems.")
    # We try to clean the maybe existing VSCodeServer module
    maybe_clean_vscode_module()
    # We execute the command in Main
    Base.eval(Main, block)
    try
        get_vscode()
        "VSCode succesfully connected!"
    catch
        rethrow()
    end
end
# This function just rewrite the cell input to contain a begin end block
function connect_vscode(; skip_pluto_check = false)
    skip_pluto_check || check_pluto() || return nothing
    out = :(html"""
    <script>
        const cell = currentScript.closest('pluto-cell')
        const CodeMirror = cell.querySelector('pluto-input')?.querySelector('.cm-editor')?.CodeMirror
        CodeMirror?.setValue("@connect_vscode begin\n\t\nend")
    </script>
    """)
end