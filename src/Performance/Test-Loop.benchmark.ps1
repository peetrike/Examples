#Requires -Version 2
# Requires -Module BenchPress

param (
    $Min = 10,
    $Max = 100000,
    $Repeat = 10
)

filter SummaFilter { $script:sum += $_ }
function SummaFunction {
    begin { $sum = 0 }
    process { $sum += $_ }
    end { $sum }
}

$Technique = @{
    'Foreach-Object smpl' = {
        $sum = 0
        $data | ForEach-Object { $sum += $_ }
        $sum
    }
    'Foreach-Object Full' = {
        $data | ForEach-Object -Begin { $sum = 0 } -Process { $sum += $_ } -End { $sum }
    }
    'Pipe to ScriptBlock' = {
        $sum = 0
        $data | . { process { $sum += $_ } }
        $sum
    }
    'Pipe to sb Full'     = {
        $sum = 0
        $data | . {
            begin { $sum = 0 }
            process { $sum += $_ }
            end { $sum }
        }
    }
    'Pipe to Filter'      = {
        $sum = 0
        $data | SummaFilter
        $sum
    }
    'Pipe to Function'    = {
        $data | SummaFunction
    }
    'For (no caching)'    = {
        $sum = 0
            # antipattern
            # access the array count on each iteration
        for ($i = 0 ; $i -lt $data.count; $i++) {
            $sum += $data[$i]
        }
        $sum
    }
    'For (with cache)'    = {
            # capture the count; cache it
        $count = $data.count
        $sum = 0
            # use the $count variable in the
            # for loop and improve performance 4x
        for ($i = 0 ; $i -lt $count; $i++) {
            $sum += $data[$i]
        }
        $sum
    }
    'While (with cache)'  = {
            # capture the count, cache it
        $count = $data.count
        $sum = 0
        $i = 0
            # use the $count variable in the
            # while loop and improve performance
        while ($i -lt $count) {
            $sum += $data[$i]
            $i++
        }
        $sum
    }
    'foreach'             = {
        $sum = 0
        foreach ($item in $data) { $sum += $item }
        $sum
    }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique += @{
        'Foreach() method' = {
            $sum = 0
            $data.foreach({ $sum += $_ })
            $sum
        }
    }
} else {
    Write-Verbose -Message ('PowerShell 2: {0} times' -f $Max)
    Import-Module .\measure.psm1
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    $data = 1..$iterations
    Measure-Benchmark -RepeatCount $Repeat -GroupName $Iterations -Technique $Technique
}
