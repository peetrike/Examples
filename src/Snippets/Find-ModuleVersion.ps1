#Requires -Modules @{ModuleName = 'PowerShellGet'; MaximumVersion = 2.99}
<#
    .SYNOPSIS
        Find local modules that have more than 2 versions on disk
    .DESCRIPTION

#>

[CmdletBinding()]
param (
        [ValidateSet('AllUsers', 'CurrentUser')]
    $Scope = 'AllUsers',
        [ValidateRange(1, 10)]
    $VersionCount = 2
)

$PathName = $Scope + 'Modules'

$ModulePath = $PSGetPath.$PathName

Get-ChildItem -Path $ModulePath\* -Include * -Directory |
    Group-Object { $_.Parent.Name } |
    Where-Object Count -gt $VersionCount
