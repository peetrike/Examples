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

$Accelerator = {
    [Version] ([wmi] 'Win32_OperatingSystem=@').Version
}

$DotNet = {
    [System.Environment]::OSVersion.Version
}
$WmiFull = {
    [Version] (Get-WmiObject -Class Win32_OperatingSystem).Version
}
$WmiVersion = {
    [Version] (Get-WmiObject -Class Win32_OperatingSystem -Property Version).Version
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique = @{
        'GCIM only version' = {
            [Version] (Get-CimInstance -ClassName Win32_OperatingSystem -Property Version).Version
        }
        'GCIM full'         = {
            [Version] (Get-CimInstance -ClassName Win32_OperatingSystem).Version
        }
        'Accelerator'       = $Accelerator
        '.NET'              = $DotNet
    }

    if ($PSVersionTable.PSVersion.Major -le 5) {
        $Technique += @{
            'GWMI full'     = $WmiFull
            'GWMI specific' = $WmiVersion
        }
    }

    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1

    Measure-ScriptBlock -Method '.NET' -Iterations $Max -ScriptBlock $DotNet
    Measure-ScriptBlock -Method 'GWMI specific' -Iterations $Max -ScriptBlock $WmiVersion
    Measure-ScriptBlock -Method 'GWMI full' -Iterations $Max -ScriptBlock $WmiFull
    Measure-ScriptBlock -Method 'Accelerator' -Iterations $Max -ScriptBlock $Accelerator
}
