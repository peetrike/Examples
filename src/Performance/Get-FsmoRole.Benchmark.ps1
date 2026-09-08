#Requires -Version 2.0
# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'result')]
param (
    $Min = 1,
    $Max = 100
)

function Get-FsmoRole {
    param (
            [Parameter(Position = 1)]
            [string[]]
        $Role = '*'
    )

    $ForestMap = @{
        NamingRoleOwner = 'DomainNamingMaster'
        SchemaRoleOwner = 'SchemaMaster'
    }
    $DomainMap = @{
        InfrastructureRoleOwner = 'InfrastructureMaster'
        PdcRoleOwner            = 'PDCEmulator'
        RidRoleOwner            = 'RIDMaster'
    }

    $ForestRole = [DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest() | Select-Object *owner
    $DomainRole = [DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() | Select-Object *owner

    $OutputProps = @{}
    foreach ($r in $ForestRole.psobject.Properties.Name -like $Role) {
        $roleName = $ForestMap[$r]
        $OutputProps[$roleName] = $ForestRole.$r
    }
    foreach ($r in $DomainRole.psobject.Properties.Name -like $Role) {
        $roleName = $DomainMap[$r]
        $OutputProps[$roleName] = $DomainRole.$r
    }
    [PSCustomObject] $OutputProps
}

$Technique = @{
    '.Net'       = { Get-FsmoRole }
    'netdom.exe' = {
        $RoleObj = @{}
        netdom.exe query fsmo |
            Select-Object -First 5 |
            ForEach-Object {
                $role, $owner = $_ -split ' {2,}'
                $RoleObj[$role] = $owner
            }
        New-Object -TypeName psobject -Property $RoleObj
    }
    'netdom one' = {
        netdom.exe query fsmo |
            Select-Object -First 5 |
            ForEach-Object { $_ -split ' {2,}' -join ',' } |
            ConvertFrom-Csv -Header Role, Owner
    }
}

if ($PSVersionTable.PSVersion.Major -eq 2) {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
}
