#Requires -Version 3

[CmdletBinding(
    DefaultParameterSetName = 'set1'
)]
param (
        [switch]
    $ToFile,
    $Param2 = 'Parameeter'
)

$result = @(
    '$PWD = {0}' -f $PWD
    '.NET current directory = {0}' -f [Environment]::CurrentDirectory
    'Home Folder: {0}' -f (Get-PSProvider -PSProvider FileSystem).Home
    '$PSScriptRoot = {0}' -f $PSScriptRoot
    '$PSCommandPath = {0}' -f $PSCommandPath
    'Source: {0}' -f $MyInvocation.MyCommand.Source
    'My Invocation Path: {0}' -f $MyInvocation.MyCommand.Path
    'My Invocation name: {0}' -f $MyInvocation.MyCommand.Name
    'ParameterSet name: {0}' -f $PsCmdlet.ParameterSetName

    'Bound Parameters:'
    $PSBoundParameters
)

if ($ToFile) {
    $FilePath = Join-Path -Path $PWD -ChildPath 'tulemus.txt'
    Set-Content -Path $FilePath -Value $result
} else {
    $result
}
