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
        foreach ($i in 1..$Iterations) {
            $string += "Number $i `n"
        }
    }
    '-join'         = {
        $Iterations = $Iterations
        $string = @(
            foreach ($i in 1..$Iterations) { "Number $i `n" }
        ) -join ''
    }
    'StringBuilder' = {
        $sb = [Text.StringBuilder] 4
        $Iterations = $Iterations
        foreach ($i in 1..$Iterations) { [void] $sb.Append("Number $i `n") }
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
