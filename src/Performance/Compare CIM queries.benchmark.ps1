#Requires -Version 2.0
# Requires -Module BenchPress

[CmdletBinding()]
param (
    $Min = 1,
    $Max = 100
)

function Get-CimObject {
    [CmdletBinding(
        DefaultParameterSetName = 'Default'
    )]
    param (
            [Parameter(
                Mandatory = $true,
                ParameterSetName = 'Default',
                Position = 0
            )]
            [string]
        $ClassName,
            [Parameter(
                ParameterSetName = 'Default'
            )]
            [string]
        $Filter,
            [Parameter(
                ParameterSetName = 'Default'
            )]
            [string[]]
        $Property = '*',
            [Parameter(
                Mandatory = $true,
                ParameterSetName = 'Query'
            )]
            [string]
        $Query,
            [string]
        $Namespace
    )

    if ($PSCmdlet.ParameterSetName -eq 'Default') {
        $Query = @(
            'SELECT {0} FROM {1}' -f ($Property -join ','), $ClassName
            if ($Filter) { 'WHERE {0}' -f $Filter }
        ) -join ' '
    }

    $searcher = [wmisearcher] $Query

    if ($Namespace) { $searcher.Scope = [System.Management.ManagementScope] $Namespace }

    $searcher.Get()
}

$Technique = @{
    'WMI object'       = {
        $Property = 'PartOfDomain'
        ([wmi] "Win32_ComputerSystem='$env:COMPUTERNAME'").$Property
    }
    'Searcher plain S' = {
        $Property = 'PartOfDomain'
        ([wmisearcher] "SELECT $Property FROM Win32_ComputerSystem").Get() |
            Select-Object -ExpandProperty $Property
    }
    'Searcher plain G' = {
        $Property = 'PartOfDomain'
        ([wmisearcher] 'SELECT * FROM Win32_ComputerSystem').Get() |
            Select-Object -ExpandProperty $Property
    }
    'CimObject S'      = {
        $Property = 'PartOfDomain'
        Get-CimObject -ClassName 'Win32_ComputerSystem' -Property $Property |
            Select-Object -ExpandProperty $Property
    }
    'CimObject G'      = {
        $Property = 'PartOfDomain'
        Get-CimObject -ClassName 'Win32_ComputerSystem' |
            Select-Object -ExpandProperty $Property
    }
    'CimObject Query'  = {
        $Property = 'PartOfDomain'
        Get-CimObject -Query 'Select * From Win32_ComputerSystem' |
            Select-Object -ExpandProperty $Property
    }
}

if ($PSVersionTable.PSVersion.Major -ge 3) {
    $Technique += @{
        'CimInstance S' = {
            $Property = 'PartOfDomain'
            Get-CimInstance Win32_ComputerSystem -Property $Property | Select-Object -ExpandProperty $Property
        }
        'CimInstance G' = {
            $Property = 'PartOfDomain'
            Get-CimInstance Win32_ComputerSystem | Select-Object -ExpandProperty $Property
        }
    }
}

if ($PSVersionTable.PSVersion.Major -lt 6) {
    $Technique += @{
        'WmiObject S' = {
            $Property = 'PartOfDomain'
            Get-WmiObject Win32_ComputerSystem -Property $Property | Select-Object -ExpandProperty $Property
        }
        'WmiObject G' = {
            $Property = 'PartOfDomain'
            Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty $Property
        }
    }
}

if ($PSVersionTable.PSVersion.Major -eq 2) {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
}
