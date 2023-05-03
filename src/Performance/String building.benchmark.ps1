# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'string')]
param (
    $Min = 10,
    $Max = 10000,
    $Repeat = 1
)

$Adding = {
    $string = ''
    $Iterations = $Iterations
    1..$Iterations | ForEach-Object {
        $string += 'tere'
    }
}
$Join = {
    $Iterations = $Iterations
    $string = @(
        1..$Iterations | ForEach-Object { 'tere' }
    ) -join ''
}
$Builder = {
    $sb = [Text.StringBuilder] 4
    $Iterations = $Iterations
    1..$Iterations | ForEach-Object { [void] $sb.Append('tere') }
    $string = $sb.ToString()
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $Repeat -Technique @{
            'string +='     = $Adding
            '-join'         = $Join
            'StringBuilder' = $Builder
        } -GroupName ('{0} times' -f $iterations)
    }
} else {
    Import-Module .\measure.psm1

    @(
        Measure-ScriptBlock -Method 'string +=' -Iterations $Repeat -ScriptBlock $Adding
        Measure-ScriptBlock -Method '-join' -Iterations $Repeat -ScriptBlock $Join
        Measure-ScriptBlock -Method 'StringBuilder' -Iterations $Repeat -ScriptBlock $Builder
    ) | Sort-Object -Property TotalMilliseconds
}
