#Requires -Version 2
# Requires -Modules BenchPress

param (
    $Min = 10,
    $Max = 1000,
    $Repeat = 1
)

$source = '1.2.3.4;10.11.12.13'
$IP = '1.2.3.4'

$Technique = @{
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
}

if ($PSVersionTable.PSVersion.Major -eq 2) {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $Repeat -Technique $Technique -GroupName ('{0} times' -f $iterations)
}
