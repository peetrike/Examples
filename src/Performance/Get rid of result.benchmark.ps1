#Requires -Version 2
# Requires -Module BenchPress

[CmdletBinding()]
param (
    $Min = 10,
    $Max = 10000
)

$Technique = @{
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
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message ('{0} times]' -f $Max)
    Import-Module .\measure.psm1

    Measure-ScriptBlock -Iterations $Max -Technique $Technique
}
