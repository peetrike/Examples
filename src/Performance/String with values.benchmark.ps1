#Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'result')]
param (
    $Min = 100,
    $Max = 100000
)

$value1 = 'one'
$value2 = 'two'
for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
        'values in string'    = {
            $result = "this is 1: $value1 and 2: $value2"
        }
        'concatenation'       = {
            $result = "this is 1: " + $value1 + " and 2: " + $value2
        }
        'Single quote concat' = {
            $result = 'this is 1: ' + $value1 + ' and 2: ' + $value2
        }
        'StringBuilder'       = {
            $sb = [Text.StringBuilder] @{ Capacity = 26 }
            $null = $sb.Append("this is 1: ")
            $null = $sb.Append($value1)
            $null = $sb.Append(" and 2: ")
            $null = $sb.Append($value2)
            $result = $sb.tostring()
        }
        '-f operator'         = {
            $result = 'this is 1: {0} and 2: {1}' -f $value1, $value2
        }
        '-join operator'      = {
            $result = "this is 1:", $value1, "and 2:", $value2 -join ' '
        }
    } -GroupName ('{0} times' -f $iterations)
}
