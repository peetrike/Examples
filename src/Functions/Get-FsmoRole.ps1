#Requires -Version 3

param (
        [Parameter(Position = 1)]
        [string[]]
    $Role
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

Get-FsmoRole @PSBoundParameters
