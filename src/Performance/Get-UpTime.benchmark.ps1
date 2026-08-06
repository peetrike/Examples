[CmdletBinding()]
param (
    $Min = 10,
    $Max = 100
)

function Get-UpTimeC {
    [OutputType([datetime], [timespan])]
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
        [Management.ManagementDateTimeConverter]::ToDateTime($WmiObject.$Property)
    }

    if ($Since.IsPresent) {
        $LastBootTime
    } else {
        New-TimeSpan -Start $LastBootTime
    }
}

function Get-UpTimeS {
    [OutputType([datetime], [timespan])]
    [CmdletBinding()]
    param (
            [switch]
        $Since
    )

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

function Get-UpTimeA {
    [OutputType([datetime], [timespan])]
    [CmdletBinding()]
    param (
            [switch]
        $Since
    )

    $Property = 'LastBootUpTime'
    $Class = 'Win32_OperatingSystem'

    $LastBoot = ([wmi] "$Class=@").$Property
    $LastBootTime = [Management.ManagementDateTimeConverter]::ToDateTime($LastBoot)

    if ($Since) {
        $LastBootTime
    } else {
        New-TimeSpan -Start $LastBootTime
    }
}

function Get-UpTimeW {
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
        $Class = 'Win32_OperatingSystem'
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

$Technique = @{
    Cmdlet      = { Get-UpTimeC }
    Searcher    = { Get-UpTimeS }
    stopWatch   = { Get-UpTimeW }
    Accelerator = { Get-UpTimeA }
    sinceC      = { Get-UpTimeC -Since }
    sinceS      = { Get-UpTimeS -Since }
    sinceW      = { Get-UpTimeW -Since }
    sinceA      = { Get-UpTimeA -Since }
}

if ($PSVersionTable.PSVersion.Major -gt 5){
    $Technique += @{
        PS7    = { Get-Uptime }
        sinceP = { Get-Uptime -Since }
    }
}

if ($PSVersionTable.PSVersion.Major -eq 2) {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName "$iterations times"
}
