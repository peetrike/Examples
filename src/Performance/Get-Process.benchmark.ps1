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

$Technique = @{
    '.NET direct'  = {
        [Diagnostics.Process]::GetProcessById($PID).Name
    }
    '.NET current' = {
        [Diagnostics.Process]::GetcurrentProcess().Name
    }
    'cmdlet'       = {
        (Get-Process -Id $PID).Name
    }
    'Accelerator'  = {
        ([wmi] "Win32_Process.Handle=$PID").Name
    }
    'Searcher'     = {
        ([wmisearcher] "select name from Win32_Process where Handle=$PID").Get().Name
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

if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique += @{
        'GCIM'         = {
            (Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $PID" -Property Name).Name
        }
        'GCIM full'   = {
            (Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $PID").Name
        }
    }

    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message ('PowerShell 2: {0} times' -f $Max)
    Import-Module .\measure.psm1

    foreach ($t in $Technique.Keys) {
        Measure-ScriptBlock -Method $t -Iterations $Max -ScriptBlock $Technique.$t
    }
}
