# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCmdLets', 'Get-CimInstance')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWMICmdlet', '')]
[CmdletBinding()]
param (
    $Min = 1,
    $Max = 10
)

if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique = @{
        'Get-Process' = {
            (Get-Process -id $PID).Name
        }
        '.NET direct' = {
            [Diagnostics.Process]::GetProcessById($PID).Name
        }
        'Accelerator' = {
            ([wmi] "Win32_Process.Handle=$PID").Name
        }
    }

    if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
        $Technique += @{
            'GCIM'      = {
                (Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $PID" -Property Name).Name
            }
            'GCIM full' = {
                (Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $PID").Name
            }
        }
    }

    if ($PSVersionTable.PSVersion.Major -le 5) {
        $Technique += @{
            'GWMI'      = {
                (Get-WmiObject -Class Win32_Process -Filter "ProcessId = $PID" -Property Name).Name
            }
            'GWMI full' = {
                (Get-WmiObject -Class Win32_Process -Filter "ProcessId = $PID").Name
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
        [Diagnostics.Process]::GetProcessById($PID).Name
    }
    Measure-ScriptBlock -Method 'cmdlet' -Iterations $Max -ScriptBlock { (Get-Process -id $PID).Name }
    Measure-ScriptBlock -Method 'Accelerator' -Iterations $Max -ScriptBlock {
        ([wmi] "Win32_Process.Handle=$PID").Name
    }

    Measure-ScriptBlock -Method 'WMI' -Iterations $Max -ScriptBlock {
        (Get-WmiObject -Class Win32_Process -Filter "ProcessId = $PID" -Property Name).Name
    }
}
