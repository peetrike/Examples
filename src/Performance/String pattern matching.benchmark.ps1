# Requires -Modules benchpress

[CmdletBinding()]
param (
    $Min = 100,
    $Max = 10000
)

$string = 'tere vana kere'
$pattern = '*vana*'
$rePattern = 'vana'

$Wildcard = [Management.Automation.WildcardPattern] $pattern
$regex = [Text.RegularExpressions.Regex] $rePattern

$technique = @{
    '-like pattern'  = {
        $string -like $pattern
    }
    '-match pattern' = {
        $string -match $rePattern
    }
    'WildCard'       = {
        $Wildcard.IsMatch($string)
    }
    'Regex'          = {
        $regex.Match($string).Success
    }
    'Static regex'   = {
        [regex]::IsMatch($string, $rePattern)
    }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $technique -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1

    foreach ($key in $technique.Keys) {
        Measure-ScriptBlock -Method $key -Iterations $Max -ScriptBlock $technique.$key
    }
}
