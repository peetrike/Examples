#Requires -Version 2

function Get-UName {
    [Alias('uname')]
    [CmdletBinding(
        DefaultParameterSetName = 'Specific'
    )]
    param (
            [Parameter(
                ParameterSetName = 'All'
            )]
            [switch]
        $All,
            [Parameter(
                ParameterSetName = 'Specific'
            )]
            [switch]
        $System,
            [Parameter(
                ParameterSetName = 'Specific'
            )]
            [switch]
        $Name,
            [Parameter(
                ParameterSetName = 'Specific'
            )]
            [switch]
        $Version,
            [Parameter(
                ParameterSetName = 'Specific'
            )]
            [switch]
        $Release,
            [Parameter(
                ParameterSetName = 'Specific'
            )]
            [switch]
        $Processor,
            [switch]
        $Wmi
    )


    $ReleaseData = if ($Wmi) {
        ([wmisearcher] 'Select Caption, CSDVersion, Version FROM Win32_OperatingSystem').Get() |
            Select-Object -Property Version, CsdVersion, @{
            Name       = 'ProductName'
            Expression = { $_.Caption }
        }
    } else {
        $RegPath = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion'
        Get-ItemProperty -Path $RegPath | Select-Object -Property ProductName, CSDVersion
    }

    $OutputData = @{
        System    = 'Windows'
        Name      = $env:COMPUTERNAME
        Version   = if ($UseWmi) {
            $ReleaseData.Version
        } else {
            [Environment]::OSVersion.Version.ToString().Split('.')[0..2] -join '.'
        }
        Release   = @(
            $ReleaseData.ProductName
            if ($ReleaseData.CsdVersion) { $ReleaseData.CsdVersion }
        ) -join ' '
        Processor = 'x' + ($env:PROCESSOR_ARCHITECTURE -replace '\D')
    }

    if ($All) {
        @(
            $OutputData.System
            $OutputData.Name
            $OutputData.Version
            $OutputData.Release
            $OutputData.Processor
        ) -join ' '
    } elseif ($PSBoundParameters.Keys.Count) {
        @(
            $PSBoundParameters.Keys | ForEach-Object { $OutputData[$_] }
        ) -join ' '
    } else { $OutputData.System }
}
