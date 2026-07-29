[CmdletBinding(
    SupportsShouldProcess
)]
param ()

function test {
    [CmdletBinding(
        SupportsShouldProcess
    )]
    param ()
    [PSCustomObject]@{
        Verbose = $PSBoundParameters['Verbose']
        Debug   = $PSBoundParameters.ContainsKey('Debug')
        WhatIf  = $PSBoundParameters['WhatIf']
        Confirm = $PSBoundParameters['Confirm']
    }
}

Write-Warning -Message ('Verbose is {0}' -f $PSBoundParameters['Verbose'])
if ($PSBoundParameters['Whatif']) {
    Write-Warning -Message 'Whatif present, skipping'
} else {
    test @PSBoundParameters
}
