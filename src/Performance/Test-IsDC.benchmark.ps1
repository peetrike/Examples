# Requires -Module BenchPress

[CmdletBinding()]
param (
    $Min = 10,
    $Max = 100
)

$Technique = @{
    'OS Generic'  = {
        ([wmisearcher] 'SELECT * FROM Win32_OperatingSystem').Get().ProductType
    }
    'OS Specific' = {
        ([wmisearcher] 'SELECT ProductType FROM Win32_OperatingSystem').Get().ProductType
    }
    'CS Generic'  = {
        ([wmisearcher] 'SELECT * FROM Win32_ComputerSystem').Get().DomainRole
    }
    'CS Specific' = {
        ([wmisearcher] 'SELECT DomainRole FROM Win32_ComputerSystem').Get().DomainRole
    }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message ('PowerShell 2: {0} times' -f $Max)
    Import-Module .\measure.psm1

    foreach ($key in $Technique.Keys) {
        Measure-ScriptBlock -Method $key -Iterations $Max -ScriptBlock $Technique.$key
    }
}
