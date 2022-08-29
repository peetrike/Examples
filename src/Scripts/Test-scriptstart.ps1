#Requires -Version 3

[CmdletBinding(
    DefaultParameterSetName = 'set1'
)]
param (
        [switch]
    $Param1,
    $Param2 = 'Parameeter'
)

'$PSScriptRoot = {0}' -f $PSScriptRoot
'$PSCommandPath = {0}' -f $PSCommandPath
'Source: {0}' -f $MyInvocation.MyCommand.Source
'My Invocation Path: {0}' -f $MyInvocation.MyCommand.Path
'My Invocation name: {0}' -f $MyInvocation.MyCommand.Name
'ParameterSet name: {0}' -f $PsCmdlet.ParameterSetName

'Bound Parameters:'
$PSBoundParameters
