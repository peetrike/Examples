#Requires -Module BenchPress
#Requires -Version 3.0

param (
    $Min = 10,
    $Max = 10000
)

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
        'Out-Null' = {
            [Environment]::OSVersion | Out-Null
        }
        'Redirect' = {
            [Environment]::OSVersion > $null
        }
        '$null ='  = {
            $null = [Environment]::OSVersion
        }
        '[void]'   = {
            [void] [Environment]::OSVersion
        }
    } -GroupName ('{0} times' -f $iterations)
}
