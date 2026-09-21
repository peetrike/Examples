#Requires -Version 2.0
# Requires -Module BenchPress

[CmdletBinding()]
param (
    $Min = 1,
    $Max = 100
)

try {
        $null = [Microsoft.PowerShell.Commands.DomainRole]::BackupDomainController
} catch {
    Add-Type -TypeDefinition @'
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
'@
}

$Technique = @{
    'Service'     = {
        try {
            $null = Get-Service ntds -ErrorAction Stop
            $true
        } catch {
            $false
        }
    }
    'CS Specific' = {
        $Property = 'DomainRole'
        [Microsoft.PowerShell.Commands.DomainRole] $Role =
            ([wmisearcher] "SELECT $Property FROM Win32_ComputerSystem").Get() |
                Select-Object -ExpandProperty $Property
        @(
            [Microsoft.PowerShell.Commands.DomainRole]::BackupDomainController
            [Microsoft.PowerShell.Commands.DomainRole]::PrimaryDomainController
        ) -contains $Role
    }
    'CS Generic'  = {
        $Property = 'DomainRole'
        [Microsoft.PowerShell.Commands.DomainRole] $Role =
            ([wmisearcher] 'SELECT * FROM Win32_ComputerSystem').Get() |
                Select-Object -ExpandProperty $Property
        @(
            [Microsoft.PowerShell.Commands.DomainRole]::BackupDomainController
            [Microsoft.PowerShell.Commands.DomainRole]::PrimaryDomainController
        ) -contains $Role
    }
    'CS WMI'      = {
        [Microsoft.PowerShell.Commands.DomainRole] $Role =
            ([wmi] "Win32_ComputerSystem='$env:COMPUTERNAME'").DomainRole

        @(
            [Microsoft.PowerShell.Commands.DomainRole]::BackupDomainController
            [Microsoft.PowerShell.Commands.DomainRole]::PrimaryDomainController
        ) -contains $Role
    }
    'OS Specific' = {
        $Property = 'ProductType'
        [Microsoft.PowerShell.Commands.ProductType] $Role =
            ([wmisearcher] "SELECT $Property FROM Win32_OperatingSystem").Get() |
                Select-Object -ExpandProperty $Property

        $Role -eq [Microsoft.PowerShell.Commands.ProductType]::DomainController
    }
    'OS Generic'  = {
        [Microsoft.PowerShell.Commands.ProductType] $Role =
            ([wmisearcher] 'SELECT * FROM Win32_OperatingSystem').Get() |
                Select-Object -ExpandProperty ProductType

        $Role -eq [Microsoft.PowerShell.Commands.ProductType]::DomainController
    }
    'OS WMI'      = {
        [Microsoft.PowerShell.Commands.ProductType] $Role = ([wmi] 'Win32_OperatingSystem=@').ProductType
        $Role -eq [Microsoft.PowerShell.Commands.ProductType]::DomainController
    }
}

if ($PSVersionTable.PSVersion.Major -eq 2) {
    Write-Verbose -Message ('PowerShell 2: {0} times' -f $Max)
    Import-Module .\measure.psm1
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
}
