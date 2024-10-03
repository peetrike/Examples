#Requires -Version 2
# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Get-WmiObject')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCmdLets', 'Get-CimInstance')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWMICmdlet', '')]
[CmdletBinding()]
param (
    $Min = 1,
    $Max = 100
)

$ClassName = 'Win32_ComputerSystem'
$PropertyName = 'Name'

$Technique = @{
    DotNet      = { [environment]::MachineName }
    Environment = { $env:COMPUTERNAME }
    Executable  = { hostname.exe }
    Accelerator = {
        $className = $ClassName
        $propertyName = $PropertyName
        ([wmisearcher] ('select {1} from {0}' -f $className, $propertyName)).Get().$propertyName
    }
}

$wmiTechnique = @{
    'GWMI full'     = {
        $className = $ClassName
        $propertyName = $PropertyName
        (Get-WmiObject -Class $className).$propertyName
    }
    'GWMI specific' = {
        $className = $ClassName
        $propertyName = $PropertyName
        (Get-WmiObject -Class $className -Property $propertyName).$PropertyName
    }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique += @{
        FQDN        = { [Net.Dns]::GetHostEntry('').HostName }
        'CIM Full'     = {
            $className = $ClassName
            $propertyName = $PropertyName
            (Get-CimInstance -ClassName $className).$propertyName
        }
        'CIM Specific' = {
            $className = $ClassName
            $propertyName = $PropertyName
            (Get-CimInstance -ClassName $className -Property $propertyName).$propertyName
        }
    }

    if ($PSVersionTable.PSVersion.Major -le 5) {
        $Technique += $wmiTechnique
    }

    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1

    $Technique += $wmiTechnique
   @(
        foreach ($t in $Technique.Keys) {
            Measure-ScriptBlock -Method $t -Iterations $Max -ScriptBlock $Technique.$t
        }
    ) | Sort-Object Time
}
