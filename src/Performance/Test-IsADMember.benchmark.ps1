# Requires -Module BenchPress

[CmdletBinding()]
param (
    $Min = 1,
    $Max = 100
)

$Technique = @{
    '.NET'                  = {
        try {
            [bool] [DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()
        } catch {
            $false
        }
    }
    'PartOfDomain WMI'      = {
        $Property = 'PartOfDomain'
        ([wmi] "Win32_ComputerSystem='$env:COMPUTERNAME'").$Property
    }
    'PartOfDomain specific' = {
        $Property = 'PartOfDomain'
        ([wmisearcher] "SELECT $Property FROM Win32_ComputerSystem").Get() |
            Select-Object -ExpandProperty $Property
    }
    'PartOfDomain generic'  = {
        $Property = 'PartOfDomain'
        ([wmisearcher] 'SELECT * FROM Win32_ComputerSystem').Get() |
            Select-Object -ExpandProperty $Property
    }
    'DomainRole Specific'   = {
        $Property = 'DomainRole'
        $Role = ([wmisearcher] "SELECT $Property FROM Win32_ComputerSystem").Get() |
            Select-Object -ExpandProperty $Property
        0, 2 -notcontains $Role
    }
    'DomainRole Generic'    = {
        $Property = 'DomainRole'
        $Role = ([wmisearcher] 'SELECT * FROM Win32_ComputerSystem').Get() |
            Select-Object -ExpandProperty $Property
        0, 2 -notcontains $Role
    }
    'DomainRole WMI'        = {
        $Property = 'DomainRole'
        $Role = ([wmi] "Win32_ComputerSystem='$env:COMPUTERNAME'").$Property
        0, 2 -notcontains $Role
    }
}


if ($PSVersionTable.PSVersion.Major -gt 2) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message ('PowerShell 2: {0} times' -f $Max)
    Import-Module .\measure.psm1

    foreach ($key in $Technique.Keys) {
        Measure-ScriptBlock -Method $key -Iterations $Max -ScriptBlock $Technique.$key
    }
}
