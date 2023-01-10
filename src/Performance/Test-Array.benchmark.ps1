# Requires -Version 3
# Requires -Modules BenchPress

param (
    $Min = 10,
    $Max = 10000,
    $Repeat = 1
)


if ($PSVersionTable.PSVersion.Major -gt 2) {
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
} else {
    Import-Module .\measure.psm1

    Measure-ScriptBlock -Method 'Array += in a loop' -Iterations $Repeat -ScriptBlock {
        $Array = @()
        $Iterations = $Max
        1..$Iterations | ForEach-Object {
            $Array += 'tere'
        }
    }

    Measure-ScriptBlock -Method 'Array assignment' -Iterations $Repeat -ScriptBlock {
        $Array = @()
        $Iterations = $Max
        $Array = 1..$Iterations | ForEach-Object {
            'tere'
        }
    }

    Measure-ScriptBlock -Method 'ArrayList' -Iterations $Repeat -ScriptBlock {
        $Array = [Collections.ArrayList] @()
        $Iterations = $Max
        1..$Iterations | ForEach-Object {
            [void] $Array.Add('tere')
        }
    }

    Measure-ScriptBlock -Method 'Generic list' -Iterations $Repeat -ScriptBlock {
        $Array = New-Object 'Collections.Generic.List[string]'
        $Iterations = $Max
        1..$Iterations | ForEach-Object {
            [void] $Array.Add('tere')
        }
    }

    Measure-ScriptBlock -Method 'Generic Collection' -Iterations $Repeat -ScriptBlock {
        $Array = New-Object 'Collections.ObjectModel.Collection[string]'
        $Iterations = $Max
        1..$Iterations | ForEach-Object {
            [void] $Array.Add('tere')
        }
    }

    Remove-Module measure
}
