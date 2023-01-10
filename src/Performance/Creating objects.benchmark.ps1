# Requires -Version 3.0
# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'list')]
param (
    $Min = 10,
    $Max = 100000
)

if ($PSVersionTable.PSVersion.Major -gt 2) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $Iterations -Technique @{
            'New-Object'              = {
                $list = New-Object System.Collections.Generic.List[Object]
            }
            '5.1 - [object]::new()'   = {
                $list = [Collections.Generic.List[Object]]::new()
            }
            'casting empty array'     = {
                $list = [Collections.Generic.List[Object]] @()
            }
            'casting empty hashtable' = {
                $list = [Collections.Generic.List[Object]] @{}
            }
            'strong typing'           = {
                [Collections.Generic.List[Object]] $list = @()
            }
        } -GroupName $Iterations
    }
} else {
    Import-Module .\measure.psm1

    Measure-ScriptBlock -Method 'New-Object' -Iterations $Max -ScriptBlock {
        $list = New-Object System.Collections.Generic.List[Object]
    }

    Measure-ScriptBlock -Method 'casting empty array' -Iterations $Max -ScriptBlock {
        $list = [Collections.Generic.List[Object]] @()
    }
    Measure-ScriptBlock -Method 'strong typing' -Iterations $Max -ScriptBlock {
        [Collections.Generic.List[Object]] $list = @()
    }

    Remove-Module measure
}
