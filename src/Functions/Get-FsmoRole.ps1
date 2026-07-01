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
    foreach ($r in $ForestRole.psobject.Properties.Name) {
        $OutputProps[$r] = $ForestRole.$r
    }
    foreach ($r in $DomainRole.psobject.Properties.Name) {
        $OutputProps[$r] = $DomainRole.$r
    }
    [PSCustomObject] $OutputProps | Select-Object -Property $Role
}

Get-FsmoRole @PSBoundParameters
