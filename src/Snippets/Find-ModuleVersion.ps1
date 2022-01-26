#Requires -Modules PowerShellGet
<#
    .SYNOPSIS
        Find local modules that have more than 2 versions on disk
    .DESCRIPTION

#>

[CmdletBinding()]
param (
        [ValidateSet('AllUsers', 'CurrentUser')]
    $Scope = 'AllUsers'
)

$PathName = $Scope + 'Modules'

$ModulePath = $PSGetPath.$PathName

Get-ChildItem -Path $ModulePath\* -Include * -Directory |
    Group-Object Parent |
    Where-Object Count -gt 2
