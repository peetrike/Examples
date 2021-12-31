[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Intended usage')]
param ()
function Test-PsCmdLet {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Intended usage')]
    param()

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
    $p = $PSCmdlet
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
    $f = $MyInvocation

    Write-Host -ForegroundColor Green '$PsCmdlet (function) = $p, $PsCmdlet (script) = $s'
    Write-Host -ForegroundColor Green '$MyInvocation (funcion) = $f, $MyInvocation (script) = $m'
    Write-Host -ForegroundColor Red   'Type "Exit" to return'
    function Prompt { "Test-PSCmdlet> " }
    $Host.EnterNestedPrompt()
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
$m = $MyInvocation
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
$s = $PSCmdlet

Write-Host ('$PSCommandPath = {0}' -f $PSCommandPath)
Write-Host ('$PSScriptRoot = {0}' -f $PSScriptRoot)
Write-Host ('Module name = {0}' -f $MyInvocation.MyCommand.Name)
Write-Host -ForegroundColor Red   'run Test-PsCmdlet and interactively explore automatic variables.'

Export-ModuleMember -Function Test-PsCmdLet -Variable m, s
