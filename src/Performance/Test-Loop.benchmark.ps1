#Requires -Module BenchPress

param (
    $Min = 10,
    $Max = 1000000,
    $Repeat = 1
)

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    $data = 1..$iterations
    Measure-Benchmark -RepeatCount $Repeat -Technique @{
        'Foreach-Object'        = {
            $sum = 0
            $data | ForEach-Object { $sum += $_ }
            $sum
        }
        'Pipe to ScriptBlock'   = {
            $sum = 0
            $data | . { process { $sum += $_ }}
            $sum
        }
        'Foreach Method'        = {
            $sum = 0
            $data.foreach( { $sum += $_ } )
            $sum
        }
        'For (no caching)'      = {
            $sum = 0
                # antipattern
                # access the array count on each iteration
            for ($i = 0 ; $i -lt $data.count; $i++) {
                $sum += $data[$i]
            }
            $sum
        }
        'For (with caching)'    = {
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
        'For $_ (with caching)' = {
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
        'While (with cache)'    = {
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
        'foreach'               = {
            $sum = 0
            foreach ($item in $data) { $sum += $item }
            $sum
        }
    } -GroupName $Iterations
}
