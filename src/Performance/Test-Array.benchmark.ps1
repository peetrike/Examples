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

    #region Array
    Measure-ScriptBlock -Method 'Array += in a loop' -Iterations 1 -ScriptBlock {
        $Array = @()
        $Iterations = $Max
        1..$Iterations | ForEach-Object {
            $Array += 'tere'
        }
    }
    #endregion

    #region Array assignment
    Measure-ScriptBlock -Method 'Array assignment' -Iterations 1 -ScriptBlock {
        $Array = @()
        $Iterations = $Max
        $Array = 1..$Iterations | ForEach-Object {
            'tere'
        }
    }
    #endregion

    #region ArrayList
    Measure-ScriptBlock -Method 'ArrayList' -Iterations 1 -ScriptBlock {
        $Array = [Collections.ArrayList] @()
        $Iterations = $Max
        1..$Iterations | ForEach-Object {
            [void] $Array.Add('tere')
        }
    }
    #endregion

    #region Lists
    $Array = New-Object 'Collections.Generic.List[string]'
    Measure-ScriptBlock -Method 'Generic list' -Iterations 1 -ScriptBlock {
        $Array = New-Object 'Collections.Generic.List[string]'
        $Iterations = $Max
        1..$Iterations | ForEach-Object {
            [void] $Array.Add('tere')
        }
    }
    #endregion

    #region Collection
    Measure-ScriptBlock -Method 'Generic Collection' -Iterations 1 -ScriptBlock {
        $Array = New-Object 'Collections.ObjectModel.Collection[string]'
        $Iterations = $Max
        1..$Iterations | ForEach-Object {
            [void] $Array.Add('tere')
        }
    }

    #endregion

    remove-module measure
}
