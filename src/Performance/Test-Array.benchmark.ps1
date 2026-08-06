#Requires -Version 2
# Requires -Modules BenchPress

[CmdletBinding()]
param (
    $Min = 10,
    $Max = 10000,
    $Repeat = 1
)

$Text = 'hello'

$Technique = @{
    'Array += in loop'   = {
        $text = $Text
        $iterations = $Iterations
        $Array = @()
        1..$iterations | ForEach-Object { $Array += $text }
    }
    'Array assignment'   = {
        $text = $Text
        $iterations = $Iterations
        $Array = @()
        $Array = 1..$iterations | ForEach-Object { $text }
    }
    'ArrayList'          = {
        $text = $Text
        $iterations = $Iterations
        $Array = [Collections.ArrayList] @()
        1..$iterations | ForEach-Object { [void] $Array.Add($text) }
    }
    'Generic list'       = {
        $text = $Text
        $iterations = $Iterations
        $Array = New-Object 'Collections.Generic.List[string]'
        1..$iterations | ForEach-Object { $Array.Add($text) }
    }
    'Generic Collection' = {
        $text = $Text
        $iterations = $Iterations
        $Array = New-Object 'Collections.ObjectModel.Collection[string]'
        1..$iterations | ForEach-Object { $Array.Add($text) }
    }
}

if ($PSVersionTable.PSVersion.Major -eq 2) {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1
}

for ($Iterations = $Min; $Iterations -le $Max; $Iterations *= 10) {
    Measure-Benchmark -RepeatCount $Repeat -Technique $Technique -GroupName "$Iterations times"
}
