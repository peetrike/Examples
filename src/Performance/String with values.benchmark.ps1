#Requires -Version 2
# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'result')]
param (
    $Min = 100,
    $Max = 100000
)

$value1 = 'one'
$value2 = 'two'

$Technique = @{
    'values in string' = {
        $result = "this is 1: $value1 and 2: $value2"
    }
    'Double quote +'   = {
        $result = "this is 1: " + $value1 + " and 2: " + $value2
    }
    'Single quote +'   = {
        $result = 'this is 1: ' + $value1 + ' and 2: ' + $value2
    }
    'StringBuilder'    = {
        $sb = [Text.StringBuilder] 26
        $null = $sb.Append('this is 1: ')
        $null = $sb.Append($value1)
        $null = $sb.Append(' and 2: ')
        $null = $sb.Append($value2)
        $result = $sb.ToString()
    }
    '-f operator'      = {
        $result = 'this is 1: {0} and 2: {1}' -f $value1, $value2
    }
    '-join operator'   = {
        $result = 'this is 1:', $value1, 'and 2:', $value2 -join ' '
    }
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName "$iterations times"
}
