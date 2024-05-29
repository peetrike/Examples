function Test-PsCmdlet {
    <#
        .Synopsis
            Test/Explore the $PsCmdlet variable
        .Description
            This command creates a nested prompt with $PsCmdlet set so that you explore
            the capabilities of the parameter.
            When you write an advanced function, you use $PsCmdlet to give you access to the
            PowerShell engine and a rich set of functions.  Use this function to explore what
            is available to you.
            This command copies $PsCmdlet to $p so you can use it and reduce typing.
            This is implemented by using $host.EnterNestedPrompt() which means that you have
            to type EXIT to get out of this mode.

        .Example
            Test-PsCmdlet
        .ReturnValue
            None
        .Link
            about_functions_advanced
            about_functions_advanced_methods
            about_functions_advanced_parameters
        .Notes
        AUTHOR:    RugratsVista\jsnover
        LASTEDIT:  01/10/2009 16:25:42
    #>

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Intended usage')]
    param()

    Write-Host -ForegroundColor RED "Interactively explore `$PsCmdlet .  Copied `$PsCmdlet to `$p "
    Write-Host -ForegroundColor RED 'Type "Exit" to return'
    $p = $pscmdlet
    function Prompt { 'Test-PsCmdlet> ' }
    $host.EnterNestedPrompt()
}

Test-PsCmdlet
