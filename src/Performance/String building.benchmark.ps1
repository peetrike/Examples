# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'string')]
param (
    $Min = 10,
    $Max = 10000,
    $Repeat = 1
)

if ($PSVersionTable.PSVersion.Major -gt 2) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $Repeat -Technique @{
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
                $sb = [Text.StringBuilder] ''
                $Iterations = $Iterations
                1..$Iterations | ForEach-Object { [void] $sb.Append('tere') }
                $string = $sb.ToString()
            }
        } -GroupName ('{0} times' -f $iterations)
    }
} else {
    Import-Module .\measure.psm1

    Measure-ScriptBlock -Method 'string +=' -Iterations $Repeat -ScriptBlock {
        $string = ''
        $Iterations = $Max
        1..$Iterations | ForEach-Object {
            $string += 'tere'
        }
    }

    Measure-ScriptBlock -Method '-join' -Iterations $Repeat -ScriptBlock {
        $Iterations = $Max
        $string = @(
            1..$Iterations | ForEach-Object { 'tere' }
        ) -join ''
    }

    Measure-ScriptBlock -Method 'StringBuilder' -Iterations $Repeat -ScriptBlock {
        $sb = [Text.StringBuilder] ''
        $Iterations = $Max
        1..$Iterations | ForEach-Object { [void] $sb.Append('tere') }
        $string = $sb.ToString()
    }

    Remove-Module measure
}
