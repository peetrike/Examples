param (
        [Parameter(Position = 1)]
        [string[]]
    $Role = '*'
)

function Get-FsmoRole {
    param (
            [Parameter(Position = 1)]
            [string[]]
        $Role = '*'
    )
    $ForestRole = Get-ADForest | Select-Object *master
    $DomainRole = Get-ADDomain | Select-Object PDC*, *master

    $OutputProps = @{}
    foreach ($r in $ForestRole.psobject.Properties.Name -like $Role) {
        $OutputProps[$r] = $ForestRole.$r
    }
    foreach ($r in $DomainRole.psobject.Properties.Name -like $Role) {
        $OutputProps[$r] = $DomainRole.$r
    }
    [PSCustomObject] $OutputProps
}

Get-FsmoRole @PSBoundParameters
