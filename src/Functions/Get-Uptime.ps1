#Requires -Version 2.0

[CmdletBinding()]
param (
        [switch]
    $Since
)

if ($PSVersionTable.PSVersion.Major -lt 6) {
    function Get-UpTime {
        [CmdletBinding()]
        param (
                [switch]
            $Since
        )

        $Property = 'LastBootUpTime'
        $Class = 'Win32_OperatingSystem'

        $LastBootTime = if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
            (Get-CimInstance -ClassName $Class -Property $Property).$Property
        } else {
            $WmiObject = Get-WmiObject -Class $Class -Property $Property
            #$LastBootTime = $WmiObject.ConvertToDateTime($WmiObject.LastBootUpTime)
            [Management.ManagementDateTimeConverter]::ToDateTime($WmiObject.LastBootUpTime)
        }

        if ($Since.IsPresent) {
            $LastBootTime
        } else {
            New-TimeSpan -Start $LastBootTime
        }
    }
}

Get-Uptime @PSBoundParameters
