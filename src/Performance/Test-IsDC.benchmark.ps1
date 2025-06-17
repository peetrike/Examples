# Requires -Module BenchPress

[CmdletBinding()]
param (
    $Min = 10,
    $Max = 100
)

try {
        $null = [Microsoft.PowerShell.Commands.DomainRole]::BackupDomainController
} catch {
    Add-Type -TypeDefinition @"
        using System;
        namespace Microsoft.PowerShell.Commands {
            public enum DomainRole {
                StandaloneWorkstation,
                MemberWorkstation,
                StandaloneServer,
                MemberServer,
                BackupDomainController,
                PrimaryDomainController
            }
            public enum ProductType {
                Unknown,
                Workstation,
                DomainController,
                Server
            }
        }
"@
}

$Technique = @{
    'CS Specific' = {
        $Property = 'DomainRole'
        $Role = ([wmisearcher] "SELECT $Property FROM Win32_ComputerSystem").Get() |
            Select-Object -ExpandProperty $Property
        [Microsoft.PowerShell.Commands.DomainRole] $Role
    }
    'CS Generic'  = {
        $Role = ([wmisearcher] 'SELECT * FROM Win32_ComputerSystem').Get() |
            Select-Object -ExpandProperty DomainRole
        [Microsoft.PowerShell.Commands.DomainRole] $Role
    }
    'OS Specific' = {
        $Property = 'ProductType'
        $Role = ([wmisearcher] "SELECT $Property FROM Win32_OperatingSystem").Get() |
            Select-Object -ExpandProperty $Property
        [Microsoft.PowerShell.Commands.ProductType] $Role
    }
    'OS Generic'  = {
        $Role = ([wmisearcher] 'SELECT * FROM Win32_OperatingSystem').Get() |
            Select-Object -ExpandProperty ProductType
        [Microsoft.PowerShell.Commands.ProductType] $Role
    }
    'WMI'         = {
        [Microsoft.PowerShell.Commands.ProductType] ([wmi] "Win32_ComputerSystem='$env:COMPUTERNAME'").DomainRole
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
