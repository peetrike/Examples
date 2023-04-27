#Requires -Modules benchpress

[CmdletBinding()]
param (
    $Min = 100,
    $Max = 10000
)


$string1 = 'tere vana kere'
$string2 = 'tere vana kere'

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
        '-eq'            = {
             $string1 -eq $string2
        }
        '-like pattern'  = {
            $string1 -like '*vana*'
        }
        '-like full'     = {
            $string1 -like $string2
        }
        '-match pattern' = {
            $string1 -match 'vana'
        }
        '-match full'    = {
            $string1 -match $string2
        }
    } -GroupName ('{0} times' -f $iterations)
}
