#Requires -Version 3.0
#Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'list')]
param (
    $Min = 10,
    $Max = 100000
)

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $Iterations -Technique @{
        'New-Object'              = {
            $list = New-Object System.Collections.Generic.List[Object]
        }
        '5.1 - [object]::new()'   = {
            $list = [Collections.Generic.List[Object]]::new()
        }
        'casting empty array'     = {
            $list = [Collections.Generic.List[Object]]@()
        }
        'casting empty hashtable' = {
            $list = [Collections.Generic.List[Object]]@{}
        }
        'strong typing'           = {
            [Collections.Generic.List[Object]] $list = @()
        }
    } -GroupName $Iterations
}
