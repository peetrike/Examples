function Get-EnumValue {
    [CmdletBinding()]
    param (
            [Parameter(
                ValueFromPipeline
            )]
            [type]
        $Type
    )

    [enum]::GetValues($Type) |
        Select-Object @{
            Name       = 'Name'
            Expression = { $_ }
        }, @{
            Name       = 'Value'
            Expression = { $_.value__ }
        }
}
