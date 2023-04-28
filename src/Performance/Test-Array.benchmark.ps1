#Requires -Version 2
# Requires -Modules BenchPress

[CmdletBinding()]
param (
    $Min = 10,
    $Max = 10000,
    $Repeat = 1
)

$ArrayAdd = {
    $Array = @()
    $Iterations = $Iterations
    1..$Iterations | ForEach-Object {
        $Array += 'tere'
    }
}
$Assignment = {
    $Array = @()
    $Iterations = $Iterations
    $Array = 1..$Iterations | ForEach-Object {
        'tere'
    }
}
$ArrayList = {
    $Array = [Collections.ArrayList] @()
    $Iterations = $Iterations
    1..$Iterations | ForEach-Object {
        [void] $Array.Add('tere')
    }
}
$List = {
    $Array = New-Object 'Collections.Generic.List[string]'
    $Iterations = $Iterations
    1..$Iterations | ForEach-Object {
        $Array.Add('tere')
    }
}
$Collection = {
    $Array = New-Object 'Collections.ObjectModel.Collection[string]'
    $Iterations = $Iterations
    1..$Iterations | ForEach-Object {
        $Array.Add('tere')
    }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $Repeat -Technique @{
            'Array += in loop'   = $ArrayAdd
            'Array assignment'   = $Assignment
            'ArrayList'          = $ArrayList
            'Generic list'       = $List
            'Generic Collection' = $Collection
        } -GroupName ('{0} times' -f $iterations)
    }
} else {
    $iterations = $max
    Write-Verbose -Message ('{0} times' -f $iterations)
    Import-Module .\measure.psm1

    @(
        Measure-ScriptBlock -Method 'Array += in a loop' -Iterations $Repeat -ScriptBlock $ArrayAdd
        Measure-ScriptBlock -Method 'Array assignment' -Iterations $Repeat -ScriptBlock $Assignment
        Measure-ScriptBlock -Method 'ArrayList' -Iterations $Repeat -ScriptBlock $ArrayList
        Measure-ScriptBlock -Method 'Generic list' -Iterations $Repeat -ScriptBlock $List
        Measure-ScriptBlock -Method 'Generic Collection' -Iterations $Repeat -ScriptBlock $Collection
    ) | Sort-Object TotalMilliSeconds
}
