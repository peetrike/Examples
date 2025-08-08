$ModuleName = 'SayHello'
New-Module -Name $ModuleName -ScriptBlock {
    function get-hello {
        <#
            .SYNOPSIS
                Says hello
            .DESCRIPTION
                some examples for platyPS

                - regular text
                - text having **bold** in it
        #>
        'Hello'
    }
} | Import-Module

New-CommandHelp -CommandInfo (Get-Command -Module $ModuleName) |
    Export-MarkdownCommandHelp -OutputFolder $PSScriptRoot

Get-ChildItem -Path "$PSScriptRoot\$Modulename\*.md" |
    Import-MarkdownCommandHelp |
    Export-MamlCommandHelp -OutputFolder $PSScriptRoot
