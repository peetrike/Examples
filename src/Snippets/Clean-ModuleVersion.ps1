#Requires -Version 3
#Requires -Modules @{ModuleName = 'PowerShellGet'; MaximumVersion = 2.99}

<#
    .SYNOPSIS
        Remove old installed module versions.
    .DESCRIPTION
        This script cleans up installed module versions, so that only desired number of versions is kept.
#>

[CmdletBinding(
    SupportsShouldProcess
)]
param (
        [ValidateSet('AllUsers', 'CurrentUser')]
    $Scope = 'AllUsers',
        [ValidateRange(1, 10)]
        [int]
        # Number of versions to keep
    $VersionCount = 2
)

$PathName = $Scope + 'Modules'

$ModulePath = $PSGetPath.$PathName

Get-ChildItem -Path $ModulePath\* -Include * -Directory |
    Group-Object { $_.Parent.Name } |
    Where-Object Count -GT $VersionCount |
    ForEach-Object {
        $ModuleName = $_.Name
        Write-Verbose -Message ('Processing module: {0}' -f $ModuleName)
        $DeleteList = $_.Group |
            Sort-Object { [version] $_.Name } -Descending |
            Select-Object -Skip $VersionCount
        foreach ($folder in $DeleteList) {
            $Message = 'Remove module "{0}" version' -f $ModuleName
            if ($PSCmdlet.ShouldProcess($folder.Name, $Message)) {
                Remove-Item $folder -Recurse -Force -Confirm:$false
            }
        }
    }
