function ConvertTo-HashTable {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
    process {
        $HashTable = @{}
        foreach ($key in $InputObject.PSObject.Properties.Name) {
            $HashTable[$key] = $InputObject.$key
        }
        $HashTable
    }
}
