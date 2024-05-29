function ConvertTo-TransposedObject {
    [CmdletBinding()]
    param (
            [Parameter(
                ParameterSetName = 'Pipe',
                ValueFromPipeline
            )]
        $InputObject,
            [Parameter(
                ParameterSetName = 'Pipe',
                Mandatory
            )]
            [string]
        $Key,
            [Parameter(
                ParameterSetName = 'Collection',
                Mandatory
            )]
            [object[]]
        $Collection,
            [Parameter(
                ParameterSetName = 'HashTable',
                Mandatory
            )]
            [hashtable]
        $HashTable
    )

    switch ($PSCmdlet.ParameterSetName) {
        'Collection' {
            Write-Warning -Message 'Collection not supported yet'
        }
        'HashTable' {
            [PSCustomObject] $HashTable
        }
        'Pipe' {
            $InputObject.psobject.Properties | ForEach-Object {
                $Name = $_.Name
                [pscustomobject]@{
                    Name  = $Name
                    Value = $InputObject.$Name
                }
            }
        }
    }
}
