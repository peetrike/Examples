function Test-ForeachObject {
    param(
        $data
    )

    $sum = 0
    $data | ForEach-Object { $sum += $_ }
    $sum
}

function Test-ForeachMethod {
    param(
        $data
    )

    $sum = 0
    $data.foreach({
        $sum += $_
    })
    $sum
}

function Test-ForeachMethod2 {
    param(
        $data
    )

    $sum = 0
    $data.foreach{
        $sum += $_
    }
    $sum
}

function Test-WithoutCache {
    param(
        $data
    )

    $sum = 0
    # antipattern
    # access the array count on each iteration
    for ($idx = 0 ; $idx -lt $data.count; $idx++) {
        $sum += $data[$idx]
    }
    $sum
}

function Test-WithCache {
    param(
        $data
    )

    # capture the count; cache it
    $count = $data.count
    $sum = 0
    # use the $count variable in the
    # for loop and improve performance 4x
    for ($idx = 0 ; $idx -lt $count; $idx++) {
        $sum += $data[$idx]
    }
    $sum
}

function Test-Foreach {
    param(
        $data
    )

    $sum = 0
    foreach ($item in $data) {
        $sum += $item
    }
    $sum
}

function Test-WhileWithCache ($data) {
 # capture the count, cache it
    $count = $data.count
    $sum = 0
    $idx = 0
 # use the $count variable in the
 # while loop and improve performance
    while ($idx -lt $count) {
        $sum += $data[$idx]
        $idx++
    }
    $sum
}

function ql { $args }

$tests  = ql Test-ForeachObject Test-ForeachMethod Test-WithoutCache Test-WithCache Test-ForEach Test-WhileWithCache
$ranges = ql 10 100 1000 10000 100000 1000000


$Milliseconds = @{
    Name       = 'Milliseconds'
    Expression = { $_.Time.TotalMilliSeconds }
    Format     = '{0:N3}'
    Align      = "right"
}

$(foreach ($range in $ranges) {
    foreach ($test in $tests) {
        $msg = "[{0}] Running {1} with {2} items" -f (Get-Date), $test, $range
        #Write-Host -ForegroundColor Green $msg
        Write-Progress -Activity $msg
        New-Object -TypeName PSObject -Property @{
            Time  = Measure-Command { & $test (1..$range) }
            Range = $range
            Test  = $test
        }
    }
}) | Format-Table Test, Range, $Milliseconds -AutoSize
