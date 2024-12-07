# Requires -Module BenchPress

[CmdletBinding()]
param (
    $Min = 10,
    $Max = 100
)

$Technique = @{
    'CS Specific' = {
        $Property = 'DomainRole'
        ([wmisearcher] "SELECT $Property FROM Win32_ComputerSystem").Get().$Property
    }
    'CS Generic'  = {
        ([wmisearcher] 'SELECT * FROM Win32_ComputerSystem').Get().DomainRole
    }
    'OS Specific' = {
        $Property = 'ProductType'
        ([wmisearcher] "SELECT $Property FROM Win32_OperatingSystem").Get().$Property
    }
    'OS Generic'  = {
        ([wmisearcher] 'SELECT * FROM Win32_OperatingSystem').Get().ProductType
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
