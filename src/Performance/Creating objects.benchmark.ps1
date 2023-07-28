#Requires -Version 2
# Requires -Module BenchPress

<#
    .SYNOPSIS
        Object creation benchmark test
    .DESCRIPTION
        This script measures speed of various object creation methods
    .LINK
        https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_object_creation
    .LINK
        https://learn.microsoft.com/previous-versions/powershell/module/microsoft.powershell.core/about/about_object_creation?view=powershell-3.0
    .LINK
        https://devblogs.microsoft.com/powershell/new-v3-language-features/
#>


[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'list')]
[CmdletBinding()]
param (
    $Min = 10,
    $Max = 10000
)

$Technique = @{
    'New-Object'          = {
        $list = New-Object System.Collections.Generic.List[Object]
    }
    'casting empty array' = {
        $list = [Collections.Generic.List[Object]] @()
    }
    'strong typing'       = {
        [Collections.Generic.List[Object]] $list = @()
    }
    'Activator'           = {
        $list = [Activator]::CreateInstance([Collections.Generic.List[Object]], @())
    }
}


if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique += @{
        'typecasting hashtable' = {
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
