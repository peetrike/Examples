#Requires -Module BenchPress

param (
    $Min = 10,
    $Max = 10000,
    $Repeat = 10
)

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $Repeat -Technique @{
        'String'        = {
            $string = [string]::Empty
            foreach ($i in 1..$iterations) {
                $string += [char](Get-Random -Minimum 1 -Maximum 0x0530)
            }
            $string
        }
        'StringBuilder' = {
            $string = [Text.StringBuilder]@{ Capacity = $iterations }
            foreach ($i in 1..$iterations) {
                [void] $string.Append([char](Get-Random -Minimum 1 -Maximum 0x0530))
            }
            $string.ToString()
        }
        'CharArray'     = {
            -join @(
                foreach ($i in 1..$iterations) {
                    [char](Get-Random -Minimum 1 -Maximum 0x0530)
                }
            )
        }
    } -GroupName ($Iterations * $Repeat)
}
