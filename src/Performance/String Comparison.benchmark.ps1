#Requires -Version 2.0
# Requires -Modules benchpress

[CmdletBinding()]
param (
    $Min = 100,
    $Max = 10000
)

$string1 = 'tere vana kere'
$string2 = 'tere vana kere'
$pattern = '*vana*'
$rePattern = 'vana'

$Wildcard = [Management.Automation.WildcardPattern] $pattern
$regex = [Text.RegularExpressions.Regex] $rePattern

$Technique = @{
    '-eq'            = {
        $string1 -eq $string2
    }
    '-like pattern'  = {
        $string1 -like $pattern
    }
    '-like full'     = {
        $string1 -like $string2
    }
    '-match pattern' = {
        $string1 -match $rePattern
    }
    '-match full'    = {
        $string1 -match $string2
    }
    'WildCard'       = {
        $Wildcard.IsMatch($string)
    }
    'Regex'          = {
        $regex.IsMatch($string)
    }
    'Regex static'   = {
        [regex]::IsMatch($string, $rePattern)
    }
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName "$iterations times"
}
