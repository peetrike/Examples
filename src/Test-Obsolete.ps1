#Requires -Version 3

<#
    .SYNOPSIS
        Shows the usage of Obsolete attribute
    .DESCRIPTION
        Shows the usage of Obsolete attribute
    .EXAMPLE
        Test-Obsolete.ps1 -OldParameter1 a

        The warning about obsolete parameter is displayed
    .LINK
        https://docs.microsoft.com/dotnet/api/system.obsoleteattribute
#>

[CmdletBinding()]
param (
        [Obsolete('You should use NewParameter')]
        [string]
        # This is old parameter and should not be used
    $OldParameter1,
        [obsolete()]
        [string]
        # This is old parameter and should not be used
    $OldParameter2,
        [string]
        # This is the new parameter
    $NewParameter
)

function Test-ObsoleteFunction {
    [CmdletBinding()]
    [obsolete('You should not use that', $true)]
    param ()

    Write-Verbose -Message 'This is obsolete function'
}

Test-ObsoleteFunction

'You used parameters:'
$PSBoundParameters
