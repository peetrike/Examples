# Requires -Module BenchPress

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'string')]
param (
    $Min = 10,
    $Max = 10000,
    $Repeat = 1
)

$Technique = @{
    'string +='     = {
        $string = ''
        $Iterations = $Iterations
        1..$Iterations | ForEach-Object {
            $string += 'tere'
        }
    }
    '-join'         = {
        $Iterations = $Iterations
        $string = @(
            1..$Iterations | ForEach-Object { 'tere' }
        ) -join ''
    }
    'StringBuilder' = {
        $sb = [Text.StringBuilder] 4
        $Iterations = $Iterations
        1..$Iterations | ForEach-Object { [void] $sb.Append('tere') }
        $string = $sb.ToString()
    }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $Repeat -Technique $Technique -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message ('PowerShell 2: {0} times' -f $Max)
    Import-Module .\measure.psm1

    foreach ($key in $Technique.Keys) {
        Measure-ScriptBlock -Method $key -Iterations $max -ScriptBlock $Technique.$key
    }
}
