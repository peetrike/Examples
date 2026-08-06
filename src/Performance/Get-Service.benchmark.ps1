#Requires -Version 2
# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCmdLets', 'Get-CimInstance')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Get-WmiObject')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWMICmdlet', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleTypes', '')]
[CmdletBinding()]
param (
    $Min = 1,
    $Max = 10
)

Add-Type -AssemblyName System.ServiceProcess
$ServiceName = 'bits'
$Property = 'Name', 'PathName'

$Technique = @{
    dotNet      = {
        $serviceName = $ServiceName
        [ServiceProcess.ServiceController] $serviceName
    }
    Cmdlet      = {
        $serviceName = $ServiceName
        Get-Service $serviceName
    }
    Accelerator = {
        $serviceName = $ServiceName
        [wmi] "Win32_Service.Name='$serviceName'"
    }
    Searcher    = {
        $serviceName = $ServiceName
        $property = $Property -join ','
        ([wmisearcher] "Select $property From Win32_Service Where Name='$serviceName'").Get()
    }
}

$wmiTechnique = @{
    WmiFull     = {
        $serviceName = $ServiceName
        Get-WmiObject -Class Win32_Service -Filter "Name = '$serviceName'"
    }
    WmiSpecific = {
        $serviceName = $ServiceName
        $property = $Property
        Get-WmiObject -Class Win32_Service -Filter "Name = '$serviceName'" -Property $property
    }
}

if ($PSVersionTable.PSVersion.Major -le 5) {
    $Technique += $wmiTechnique
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique += @{
        CimSpecific = {
            $serviceName = $ServiceName
            $property = $Property
                Get-CimInstance -ClassName Win32_Service -Filter "Name = '$serviceName'" -Property $property
        }
        CimFull     = {
            $serviceName = $ServiceName
            Get-CimInstance -ClassName Win32_Service -Filter "Name = '$serviceName'"
        }
    }

    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName "$iterations times"
    }
} else {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1

    Measure-ScriptBlock -Iterations $Max -Technique $Technique -GroupName "$Max times"
}
