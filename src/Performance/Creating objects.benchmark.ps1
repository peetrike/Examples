#Requires -Version 2
# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'list')]
[CmdletBinding()]
param (
    $Min = 10,
    $Max = 10000
)

$Technique = @{
    'New-Object'              = {
        $list = New-Object System.Collections.Generic.List[Object]
    }
    'casting empty array'     = {
        $list = [Collections.Generic.List[Object]] @()
    }
    'strong typing'           = {
        [Collections.Generic.List[Object]] $list = @()
    }
}


if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique += @{
        'casting empty hashtable' = {
            $list = [Collections.Generic.List[Object]] @{}
        }
    }

    if ($PSVersionTable.PSVersion.Major -gt 4) {
        $Technique += @{
            'Constructor' = {
                $list = [Collections.Generic.List[Object]]::new()
            }
        }
    }

    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $Iterations -Technique $Technique -GroupName $Iterations
    }
} else {
    Write-Verbose -Message ('PowerShell 2: {0} times' -f $Max)
    Import-Module .\measure.psm1

    foreach ($key in $Technique.Keys) {
        Measure-ScriptBlock -Method $key -Iterations $max -ScriptBlock $Technique.$key
    }
}
