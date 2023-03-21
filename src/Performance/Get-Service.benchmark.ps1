# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCmdLets', 'Get-CimInstance')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWMICmdlet', '')]
[CmdletBinding()]
param (
    $Min = 1,
    $Max = 10
)

Add-Type -AssemblyName System.ServiceProcess

if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique = @{
        <# 'Get-Service | Where' = {
            Get-Service | Where-Object { $_.Name -like "Bits" }
        } #>
        'Get-Service'         = {
            Get-Service "Bits"
        }
        <# '.NET | Where'        = {
            [ServiceProcess.ServiceController]::GetServices() | Where-Object { $_.Name -like 'bits' }
        } #>
        '.NET direct'         = {
            [ServiceProcess.ServiceController] 'bits'
        }
        'Accelerator'         = {
            [wmi] "Win32_Service.Name='Bits'"
        }
    }

    if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
        $Technique += @{
            'GCIM'      = {
                Get-CimInstance -ClassName Win32_Service -Filter "Name = 'BITS'" -Property Name, PathName
            }
            'GCIM full' = {
                Get-CimInstance -ClassName Win32_Service -Filter "Name = 'BITS'"
            }
        }
    }

    if ($PSVersionTable.PSVersion.Major -le 5) {
        $Technique += @{
            'GWMI'      = {
                Get-WmiObject -Class Win32_Service -Filter "Name = 'BITS'" -Property Name, PathName
            }
            'GWMI full' = {
                Get-WmiObject -Class Win32_Service -Filter "Name = 'BITS'"
            }
        }
    }

    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1
    Measure-ScriptBlock -Method '.NET' -Iterations $Max -ScriptBlock {
        [ServiceProcess.ServiceController] 'bits'
    }
    Measure-ScriptBlock -Method 'cmdlet' -Iterations $Max -ScriptBlock {
        Get-Service 'Bits'
    }
    Measure-ScriptBlock -Method 'Accelerator' -Iterations $Max -ScriptBlock {
        [wmi] "Win32_Service.Name='Bits'"
    }
    Measure-ScriptBlock -Method 'GWMI' -Iterations $Max -ScriptBlock {
        Get-WmiObject -Class Win32_Service -Filter "Name = 'BITS'" -Property Name, PathName
    }
}
