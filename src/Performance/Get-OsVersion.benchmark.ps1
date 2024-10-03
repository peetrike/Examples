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

$ClassName = 'Win32_OperatingSystem'
$PropertyName = 'Version'

$Technique = @{
    '.NET'       = {
        [System.Environment]::OSVersion.Version
    }
    AcceleratorS = {
        [Version] ([wmi] ('{0}=@' -f $ClassName)).$PropertyName
    }
    AcceleratorQ = {
        [Version] ([wmisearcher] ('Select {1} from {0}' -f $ClassName, $PropertyName)).Get().$PropertyName
    }
}


$wmiTechnique = @{
    'GWMI full'     = {
        [Version] (Get-WmiObject -Class $ClassName).Version
    }
    'GWMI specific' = {
        [Version] (Get-WmiObject -Class $ClassName -Property $PropertyName).$PropertyName
    }
}
if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique += @{
        'GCIM full'     = {
            [Version] (Get-CimInstance -ClassName $ClassName).$PropertyName
        }
        'GCIM specific' = {
            [Version] (Get-CimInstance -ClassName $ClassName -Property $PropertyName).$PropertyName
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
