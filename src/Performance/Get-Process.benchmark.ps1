#Requires -Version 2
# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Get-WmiObject')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCmdlets', 'Get-CimInstance')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWMICmdlet', '')]
[CmdletBinding()]
param (
    $Min = 1,
    $Max = 10
)

$dotNet = {
    [Diagnostics.Process]::GetProcessById($PID).Name
}
$Cmdlet = {
    (Get-Process -Id $PID).Name
}
$Accelerator = {
    ([wmi] "Win32_Process.Handle=$PID").Name
}
$WmiFull = {
    (Get-WmiObject -Class Win32_Process -Filter "ProcessId = $PID").Name
}
$WmiSpecific = {
    (Get-WmiObject -Class Win32_Process -Filter "ProcessId = $PID" -Property Name).Name
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique = @{
        '.NET direct' = $dotNet
        'cmdlet'      = $Cmdlet
        'Accelerator' = $Accelerator
        'GCIM'        = {
            (Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $PID" -Property Name).Name
        }
        'GCIM full'   = {
            (Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $PID").Name
        }
    }

    if ($PSVersionTable.PSVersion.Major -le 5) {
        $Technique += @{
            'GWMI'      = $WmiSpecific
            'GWMI full' = $WmiFull
        }
    }

    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1

    Measure-ScriptBlock -Method '.NET' -Iterations $Max -ScriptBlock $dotNet
    Measure-ScriptBlock -Method 'cmdlet' -Iterations $Max -ScriptBlock $Cmdlet

    Measure-ScriptBlock -Method 'Accelerator' -Iterations $Max -ScriptBlock $Accelerator
    Measure-ScriptBlock -Method 'WMI' -Iterations $Max -ScriptBlock $WmiSpecific
}
