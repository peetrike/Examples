#Requires -Version 2.0

[CmdletBinding()]
param (
        [SupportsWildcards()]
        [string]
    $Name = '*'
)

function Get-Accelerator {
    [CmdletBinding()]
    param (
            [SupportsWildcards()]
            [string]
        $Name = '*'
    )

    $TAType = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
    $AcceleratorList = $TAType::Get
    $AcceleratorList.Keys | Where-Object { $_ -like $Name } | ForEach-Object {
        $PropList = [ordered] @{
            Name = $_
            Type = if ($_ -like 'psobject') { [psobject] } else { $AcceleratorList.$_ }
        }
        New-Object -TypeName PSObject -Property $PropList
    }
}
# alternate approach, does not work with <5.1
<# $TAType::Add('accelerators', $TAType)
[accelerators]::get #>

Get-Accelerator @PSBoundParameters
