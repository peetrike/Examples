#Requires -Version 2.0

[CmdletBinding()]
param (
        [switch]
    $Since
)

if ($PSVersionTable.PSVersion.Major -lt 6) {
    function Get-UpTime {
        [OutputType([datetime], [timespan])]
        [CmdletBinding()]
        param (
                [switch]
            $Since
        )

        if ([Diagnostics.StopWatch]::IsHighResolution) {
            Write-Verbose -Message 'Using StopWatch'
            $Ticks = [Diagnostics.StopWatch]::GetTimestamp()
            $TimeSpan = if ([timespan]::TicksPerSecond -eq [Diagnostics.StopWatch]::Frequency) {
                [timespan] $Ticks
            } else {
                Write-Verbose -Message 'Calculating based on seconds'
                $seconds = $ticks / [Diagnostics.StopWatch]::Frequency
                New-TimeSpan -Seconds $seconds
            }

            if ($Since) {
                [datetime]::Now.Subtract($TimeSpan)
            } else {
                $TimeSpan
            }
        } else {
            Write-Verbose -Message ('Using CIM class: {0}' -f $Class)
            $Property = 'LastBootUpTime'
            $Class = 'Win32_OperatingSystem'
            $Query = 'SELECT {0} FROM {1}' -f $Property, $Class

            $LastBoot = ([wmisearcher] $Query).Get() | Select-Object -ExpandProperty $Property
            $LastBootTime = [Management.ManagementDateTimeConverter]::ToDateTime($LastBoot)

            if ($Since) {
                $LastBootTime
            } else {
                New-TimeSpan -Start $LastBootTime
            }
        }
    }
}

Get-Uptime @PSBoundParameters
