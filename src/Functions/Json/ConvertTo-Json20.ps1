function ConvertTo-Json20 {
    [CmdletBinding()]
    param (
            [parameter(
                Mandatory = $true,
                ValueFromPipeline = $true
            )]
            [object]
        $InputObject,
            [ValidateRange(1, 100)]
            [int]
        $Depth = 2
    )

    begin {
        try {
            $Serializer = New-Object System.Web.Script.Serialization.Javascriptserializer
        } catch {
            Add-Type -AssemblyName System.Web.Extensions
            $Serializer = New-Object System.Web.Script.Serialization.Javascriptserializer
        }
        $Serializer.RecursionLimit = $Depth
    }

    process {
        $Serializer.Serialize($InputObject)
    }
}
