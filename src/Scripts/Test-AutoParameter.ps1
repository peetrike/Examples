<#
    .DESCRIPTION
        The tested parameters are preference parameters that are also visible in
        functions from same script, but not in functions from custom module.

        This script shows, how these parameters can be passed, when needed
    .LINK

#>

[CmdletBinding(
    SupportsShouldProcess
)]
param (
        [switch]
    $Test
)

function test {
    [CmdletBinding(
        SupportsShouldProcess
    )]
    param (
            [switch]
        $Test
    )

    if ($DebugPreference -eq 'Inquire') {
        $DebugPreference = 'Continue'
    }

    Write-Verbose -Message 'inside function'
    Write-Debug -Message 'debug message'

    [PSCustomObject]@{
        Verbose = [bool] $PSBoundParameters['Verbose']      # $VerbosePreference is [ActionPreference]
        Debug   = $PSBoundParameters.ContainsKey('Debug')   # doesn't check for explicit false
        WhatIf  = $WhatIfPreference
        Confirm = $Confirm.IsPresent                        # doesn't work at all
        Test    = $Test
    }
}

Write-Warning -Message ('Verbose is {0}' -f $Verbose.IsPresent)
if ($PSCmdlet.ShouldProcess('test', 'run function')) {
    test @PSBoundParameters
    Write-Host 'Parameters to be passed' "`n" $PSBoundParameters "`n"
}
