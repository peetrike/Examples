#Requires -Module BenchPress
using namespace System.Text

param (
    $Min = 10,
    $Max = 100000,
    $Repeat = 1
)


for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $Repeat -Technique @{
        'String'        = {
            $string = [string]::Empty
            foreach ($i in 1..$iterations) {
                $string += [char](Get-Random -Minimum 1 -Maximum 0x0530)
            }
        }
        'StringBuilder' = {
            $string = [StringBuilder]@{ Capacity = $iterations }
            foreach ($i in 1..$iterations) {
                [void] $string.Append([char](Get-Random -Minimum 1 -Maximum 0x0530))
            }
        }
    } -GroupName ($Iterations * $Repeat)
}
