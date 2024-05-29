function Format-TransposeTable {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )] [object[]]$Object
    )
    begin { $i = 0; }

    process {
        foreach ($myObject in $Object) {
            if ($myObject.GetType().Name -eq 'hashtable' -or $myObject.GetType().Name -eq 'OrderedDictionary') {
                Write-Verbose "Format-TransposeTable - Converting HashTable/OrderedDictionary to PSCustomObject - $($myObject.GetType().Name)"
                New-Object -TypeName PsObject -Property $myObject
            } else {
                Write-Verbose "Format-TransposeTable - Converting PSCustomObject to HashTable/OrderedDictionary - $($myObject.GetType().Name)"
                $output = [ordered] @{}
                $myObject | Get-Member -MemberType Properties | ForEach-Object {
                    $name = $_.name
                    $output.$name = $myObject.$name
                }
                $output
            }
            $i += 1
        }
    }
}
