[CmdletBinding()]
param (
        [Parameter(
            ValueFromPipeline
        )]
        [string]
    $InputObject
)

begin {
    Write-Verbose -Message 'Starting script'
}

<# process {
        # You can't have process block when You expect $input to contain values in end block
    Write-Verbose -Message ('Processing input')
    #$InputObject
} #>

end {
    Write-Verbose -Message 'Ending script'
    Write-Information -InformationAction Continue -MessageData 'InputObject values'
    $InputObject

    if ($DebugPreference) { Wait-Debugger }
    Write-Information -InformationAction Continue -MessageData 'Input values'
    $input
}
