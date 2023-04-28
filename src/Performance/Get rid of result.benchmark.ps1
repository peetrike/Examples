#Requires -Version 2
# Requires -Module BenchPress

[CmdletBinding()]
param (
    $Min = 10,
    $Max = 10000
)

$cmdlet = {
    [Environment]::OSVersion | Out-Null
}
$redirect = {
    [Environment]::OSVersion > $null
}
$assignment = {
    $null = [Environment]::OSVersion
}
$void = {
    [void] [Environment]::OSVersion
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique @{
            'Out-Null' = $cmdlet
            'Redirect' = $redirect
            '$null ='  = $assignment
            '[void]'   = $void
        } -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message ('{0} times]' -f $Max)
    Import-Module .\measure.psm1

    Measure-ScriptBlock -Method 'Out-Null' -Iterations $Max -ScriptBlock $cmdlet
    Measure-ScriptBlock -Method 'Redirect' -Iterations $Max -ScriptBlock $redirect
    Measure-ScriptBlock -Method '$null =' -Iterations $Max -ScriptBlock $assignment
    Measure-ScriptBlock -Method '[void]' -Iterations $Max -ScriptBlock $void
}
