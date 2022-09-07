function ConvertTo-Json20 {
    [CmdletBinding()]
    param (
            [parameter(
                Mandatory = $true,
                ValueFromPipeline = $true
            )]
            [object]
        $InputObject
    )

    begin {
        try {
            $Serializer = New-Object System.Web.Script.Serialization.Javascriptserializer
        } catch {
            Add-Type -AssemblyName System.Web.Extensions
            $Serializer = New-Object System.Web.Script.Serialization.Javascriptserializer
        }
    }

    process {
        $Serializer.Serialize($InputObject)
    }
}
