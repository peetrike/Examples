#Requires -Version 2
# Requires -Modules BenchPress

param (
    $Min = 10,
    $Max = 1000,
    $Repeat = 1
)

$source = '1.2.3.4;10.11.12.13'
$IP = '1.2.3.4'

$Regex = {
    $source = $source
    $IP = $IP
    $iterations = $iterations
    foreach ($i in 1..$iterations) {
        $source -match $IP
    }
}
$Operator = {
    $source = $source
    $IP = $IP
    $iterations = $iterations
    foreach ($i in 1..$iterations) {
        ($source -split ';') -contains $IP
    }
}
$Method = {
    $source = $source
    $IP = $IP
    $iterations = $iterations
    foreach ($i in 1..$iterations) {
        $source.Split(';') -contains $IP
    }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $Repeat -Technique @{
            '-match'  = $Regex
            '-split'  = $Operator
            'Split()' = $Method
        } -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1

    @(
        Measure-ScriptBlock -Method '-match' -Iterations $Max -ScriptBlock $Regex
        Measure-ScriptBlock -Method '-split' -Iterations $Max -ScriptBlock $Operator
        Measure-ScriptBlock -Method 'Split()' -Iterations $Max -ScriptBlock $Method
    ) | Sort-Object -Property TotalMilliseconds
}
