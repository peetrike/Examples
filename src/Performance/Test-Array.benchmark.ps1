#Requires -Module BenchPress

param (
    $Min = 10,
    $Max = 10000,
    $Repeat = 1
)


for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $Repeat -Technique @{
        'Array += in loop'   = {
            $Array = @()
            1..$Iterations | ForEach-Object {
                $Array += 'tere'
            }
        }
        'Array assignment'   = {
            $Array = @()
            $Array = 1..$Iterations | ForEach-Object {
                'tere'
            }
        }
        'ArrayList'          = {
            $Array = [Collections.ArrayList] @()
            1..$Iterations | ForEach-Object {
                [void] $Array.Add('tere')
            }
        }
        'Generic list'       = {
            $Array = [Collections.Generic.List[string]] @()
            1..$Iterations | ForEach-Object {
                $Array.Add('tere')
            }
        }
        'Generic Collection' = {
            $Array = [Collections.ObjectModel.Collection[string]] @()
            1..$Iterations | ForEach-Object {
                $Array.Add('tere')
            }
        }
    } -GroupName ('{0} times' -f $iterations)
}
