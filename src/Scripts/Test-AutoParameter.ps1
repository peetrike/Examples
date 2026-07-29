[CmdletBinding(
    SupportsShouldProcess
)]
param ()

function test {
    [CmdletBinding(
        SupportsShouldProcess
    )]
    param ()

    if ($DebugPreference -eq 'Inquire') {
        $DebugPreference = 'Continue'
    }

    Write-Verbose -Message 'inside function'
    Write-Debug -Message 'debug message'

    [PSCustomObject]@{
        Verbose = [bool] $PSBoundParameters['Verbose']
        Debug   = $PSBoundParameters.ContainsKey('Debug')
        WhatIf  = $WhatIfPreference
        Confirm = $Confirm.IsPresent
    }
}

Write-Warning -Message ('Verbose is {0}' -f $PSBoundParameters['Verbose'])
if ($PSCmdlet.ShouldProcess('run function')) {
    test @PSBoundParameters
}
