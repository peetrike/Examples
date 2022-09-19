#Requires -Version 3
#Requires -Modules BenchPress

param (
    $Min = 10,
    $Max = 10000,
    $Repeat = 1
)


for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $Repeat -Technique @{
        'Array += in loop'   = {
            $Array = @()
            $Iterations = $Iterations
            1..$Iterations | ForEach-Object {
                $Array += 'tere'
            }
        }
        'Array assignment'   = {
            $Array = @()
            $Iterations = $Iterations
            $Array = 1..$Iterations | ForEach-Object {
                'tere'
            }
        }
        'ArrayList'          = {
            $Array = [Collections.ArrayList] @()
            $Iterations = $Iterations
            1..$Iterations | ForEach-Object {
                [void] $Array.Add('tere')
            }
        }
        'Generic list'       = {
            $Array = [Collections.Generic.List[string]] @()
            $Iterations = $Iterations
            1..$Iterations | ForEach-Object {
                $Array.Add('tere')
            }
        }
        'Generic Collection' = {
            $Array = [Collections.ObjectModel.Collection[string]] @()
            $Iterations = $Iterations
            1..$Iterations | ForEach-Object {
                $Array.Add('tere')
            }
        }
    } -GroupName ('{0} times' -f $iterations)
}
