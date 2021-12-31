#Requires -Version 2

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Intended usage')]
param ()

function Test-PsCmdLet {
    [CmdletBinding()]
    param()

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', 'p')]
    $p = $PSCmdlet
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', 's')]
    $f = $MyInvocation

    function Prompt { 'Test-PSCmdlet> ' }
    $Host.EnterNestedPrompt()
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', 'm')]
$m = $MyInvocation

Write-Host ('$PSCommandPath = {0}' -f $PSCommandPath)
Write-Host ('$PSScriptRoot = {0}' -f $PSScriptRoot)
Write-Host -ForegroundColor Red   'Interactively explore automatic variables.'
Write-Host -ForegroundColor Green '$PsCmdlet = $p, $MyInvocation (function) = $f, $MyInvocation (script) = $m'
Write-Host -ForegroundColor Red   'Type "Exit" to return'

Test-PsCmdLet
