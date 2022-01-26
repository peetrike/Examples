#Requires -Version 2

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Intended usage')]
[CmdletBinding()]
param ()

function Test-PsCmdLet {
    [CmdletBinding()]
    param()

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', 'p')]
    $p = $PSCmdlet
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', 'f')]
    $f = $MyInvocation

    function Prompt { 'Test-PSCmdlet> ' }
    $Host.EnterNestedPrompt()
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', 'm')]
$m = $MyInvocation
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', 'S')]
$s = $PSCmdlet

Write-Host ('$PSCommandPath = {0}' -f $PSCommandPath)
Write-Host ('$PSScriptRoot = {0}' -f $PSScriptRoot)
Write-Host -ForegroundColor Red   'Interactively explore automatic variables.'
Write-Host -ForegroundColor Green 'Function: $PsCmdlet = $p, $MyInvocation = $f'
Write-Host -ForegroundColor Green 'Script:   $PsCmdlet = $s, $MyInvocation = $m'
Write-Host -ForegroundColor Red   'Type "Exit" to return'

Test-PsCmdLet
