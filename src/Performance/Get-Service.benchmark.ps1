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
$dotNet = {
    [ServiceProcess.ServiceController] 'bits'
}
$Cmdlet = {
    Get-Service 'Bits'
}
$Accelerator = {
    [wmi] "Win32_Service.Name='Bits'"
}
$WmiFull = {
    Get-WmiObject -Class Win32_Service -Filter "Name = 'BITS'"
}
$WmiSpecific = {
    Get-WmiObject -Class Win32_Service -Filter "Name = 'BITS'" -Property Name, PathName
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique = @{
        'cmdlet'      = $Cmdlet
        '.NET'        = $dotNet
        'Accelerator' = $Accelerator
        'GCIM'        = {
            Get-CimInstance -ClassName Win32_Service -Filter "Name = 'BITS'" -Property Name, PathName
        }
        'GCIM full'   = {
            Get-CimInstance -ClassName Win32_Service -Filter "Name = 'BITS'"
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
    Measure-ScriptBlock -Method 'GWMI' -Iterations $Max -ScriptBlock $WmiSpecific
}
