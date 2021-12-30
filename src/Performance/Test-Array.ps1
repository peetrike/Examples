$Iterations = 10000
function Measure-ScriptBlock {
    param (
            [int]
        $Iterations = 10000,
            [string]
        $Method,
            [scriptblock]
        $ScriptBlock
    )

    $Type = @{
        Name       ='Method'
        Expression = { $Method }
    }

    1..$Iterations |
        Measure-Command $ScriptBlock |
        Select-Object -Property TotalMilliseconds, $Type
}

$Type = @{
    Name       ='Type'
    Expression = { $Array.GetType().Name }
}

#region Array (slow)
$Array = @()
1..$Iterations | Measure-Command {
    $array += 'tere'
} | Select-Object TotalMilliseconds, $Type
#endregion

#region Array
$Array = @()
Measure-Command {
    $Array = 1..$Iterations | ForEach-Object {
        'tere'
    }
} | Select-Object TotalMilliseconds, $Type
#endregion

#region ArrayList
$array = [Collections.ArrayList] @()
1..$Iterations | Measure-Command {
    [void] $Array.Add('tere')
} | Select-Object TotalMilliseconds, $Type
#endregion

#region Lists
$Array = [Collections.Generic.List[string]] @()
1..$Iterations | Measure-Command {
    $array.Add('tere')
} | Select-Object TotalMilliseconds, $Type
#endregion

#region Collection
$Array = [Collections.ObjectModel.Collection[string]] @()
1..10000 | Measure-Command {
        $Array.Add('tere')
} | Select-Object TotalMilliseconds, $Type
#endregion


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
