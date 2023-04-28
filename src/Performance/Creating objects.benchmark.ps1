#Requires -Version 2
# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'list')]
[CmdletBinding()]
param (
    $Min = 10,
    $Max = 10000
)

$cmdlet = {
    $list = New-Object System.Collections.Generic.List[Object]
}
$array = {
    $list = [Collections.Generic.List[Object]] @()
}
$strongType = {
    [Collections.Generic.List[Object]] $list = @()
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique = @{
        'New-Object'              = $cmdlet
        'casting empty array'     = $array
        'casting empty hashtable' = {
            $list = [Collections.Generic.List[Object]] @{}
        }
        'strong typing'           = $strongType
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
    Write-Verbose -Message ('{0} times]' -f $Max)
    Import-Module .\measure.psm1

    Measure-ScriptBlock -Method 'New-Object' -Iterations $Max -ScriptBlock $cmdlet
    Measure-ScriptBlock -Method 'casting empty array' -Iterations $Max -ScriptBlock $array
    Measure-ScriptBlock -Method 'strong typing' -Iterations $Max -ScriptBlock $strongType
}
