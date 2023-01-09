[CmdletBinding()]
param (
        [int]
    $Max = 10000
)
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

<#
function Test-Array {
    Param(
        $Iterations  = 100000,
        $OutputEvery = 1000
    )

    $StopWatch = [Diagnostics.Stopwatch]::StartNew()

    $Array = @()
    foreach ($i in 1..$Iterations) {
        if (-not ($i % $OutputEvery)) { "Records processed:`t{0}" -f $i }
        $Array += $i
    }

    $StopWatch.Stop()

    [PSCustomObject] @{
        Type            = $Array.GetType().Name
        ArrayCount      = $Array.Count
        DurationSeconds = [Math]::Round($StopWatch.Elapsed.TotalSeconds, 2)
        MemoryUsageMB   = [Math]::Round((Get-Process -Id $pid).WorkingSet / 1MB, 2)
    }
}

function Test-Array2 {
    Param(
        $Iterations  = 100000,
        $OutputEvery = 1000
    )

    $StopWatch = [Diagnostics.Stopwatch]::StartNew()

    $Array = @()
    $Array = foreach ($i in 1..$Iterations) {
        if (-not ($i % $OutputEvery)) { Write-Host ("Records processed:`t{0}" -f $i) }
        $i
    }

    $StopWatch.Stop()

    [PSCustomObject] @{
        Type           = $Array.GetType().Name
        ArrayCount     = $Array.Count
        'Duration(ms)' = $StopWatch.Elapsed.TotalMilliseconds
        MemoryUsageMB  = [Math]::Round((Get-Process -Id $pid).WorkingSet / 1MB, 2)
    }
}

function Test-ArrayList {
    Param(
        $Iterations  = 100000,
        $OutputEvery = 1000
    )

    $StopWatch = [Diagnostics.Stopwatch]::StartNew()

    $Array = [Collections.ArrayList] @()
    foreach ($i in 1..$Iterations) {
        if (-not ($i % $OutputEvery)) { "Records processed:`t{0}" -f $i }
        [void] $Array.Add($i)
    }

    $StopWatch.Stop()

    [PSCustomObject]@{
        Type           = $Array.GetType().Name
        ArrayCount     = $Array.Count
        'Duration(ms)' = $StopWatch.Elapsed.TotalMilliseconds
        MemoryUsageMB  = [Math]::Round((Get-Process -Id $pid).WorkingSet / 1MB, 2)
    }
}

function Test-ArrayList2 {
    Param(
        $Iterations  = 100000,
        $OutputEvery = 1000
    )

    $StopWatch = [Diagnostics.Stopwatch]::StartNew()

    $Array = [System.Collections.ArrayList]::new($Iterations)
    foreach ($i in 1..$Iterations) {
        if (-not ($i % $OutputEvery)) { "Records processed:`t{0}" -f $i }
        [void] $Array.Add($i)
    }

    $StopWatch.Stop()

    [PSCustomObject]@{
        Type           = $Array.GetType().Name + ' with capacity preallocation'
        ArrayCount     = $Array.Count
        'Duration(ms)' = $StopWatch.Elapsed.TotalMilliseconds
        MemoryUsageMB  = [Math]::Round((Get-Process -Id $pid).WorkingSet / 1MB, 2)
    }
}

function Test-List {
    Param(
        $Iterations  = 100000,
        $OutputEvery = 1000
    )

    $StopWatch = [Diagnostics.Stopwatch]::StartNew()

    $Array = [Collections.Generic.List[int]] @()
    foreach ($i in 1..$Iterations) {
        if (-not ($i % $OutputEvery)) { "Records processed:`t{0}" -f $i }
        [void]$Array.Add($i)
    }

    $StopWatch.Stop()

    [PSCustomObject] @{
        Type           = $Array.GetType().Name
        ArrayCount     = $Array.Count
        'Duration(ms)' = $StopWatch.Elapsed.TotalMilliseconds
        MemoryUsageMB  = [Math]::Round((Get-Process -Id $pid).WorkingSet / 1MB, 2)
    }
}

function Test-Collection {
    Param(
        $Iterations  = 100000,
        $OutputEvery = 1000
    )

    $StopWatch = [Diagnostics.Stopwatch]::StartNew()

    $Array = { }.Invoke()
    foreach ($i in 1..$Iterations) {
        if (-not ($i % $OutputEvery)) { "Records processed:`t{0}" -f $i }
        [void]$Array.Add($i)
    }

    $StopWatch.Stop()

    [PSCustomObject]@{
        Type           = $Array.GetType().Name
        ArrayCount     = $Array.Count
        'Duration(ms)' = $StopWatch.Elapsed.TotalMilliseconds
        MemoryUsageMB  = [Math]::Round((Get-Process -Id $pid).WorkingSet / 1MB, 2)
    }
}

function Test-Collection2 {
    Param(
        $Iterations  = 100000,
        $OutputEvery = 1000
    )

    $StopWatch = [Diagnostics.Stopwatch]::StartNew()

    $Array = [Collections.ObjectModel.Collection[int]]::new()

    foreach ($i in 1..$Iterations) {
        if (-not ($i % $OutputEvery)) { "Records processed:`t{0}" -f $i }
        [void]$Array.Add($i)
    }

    $StopWatch.Stop()

    [PSCustomObject]@{
        Type           = $Array.GetType().Name
        ArrayCount     = $Array.Count
        'Duration(ms)' = $StopWatch.Elapsed.TotalMilliseconds
        MemoryUsageMB  = [Math]::Round((Get-Process -Id $pid).WorkingSet / 1MB, 2)
    }
}
#>

remove-module measure
