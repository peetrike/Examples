#Requires -Modules BenchPress

param (
    $Min = 10,
    $Max = 1000,
    $Repeat = 1
)

$source = '1.2.3.4;10.11.12.13'
$IP = '1.2.3.4'

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $Repeat -Technique @{
        '-match'  = {
            $source = $source
            $IP = $IP
            $iterations = $iterations
            foreach ($i in 1..$iterations) {
                $source -match $IP
            }
        }
        '-split'  = {
            $source = $source
            $IP = $IP
            $iterations = $iterations
            foreach ($i in 1..$iterations) {
                ($source -split ';') -contains $IP
            }
        }
        'Split()' = {
            $source = $source
            $IP = $IP
            $iterations = $iterations
            foreach ($i in 1..$iterations) {
                $source.Split(';') -contains $IP
            }
        }
    } -GroupName ('{0} times' -f $iterations)
}
