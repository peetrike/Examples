<#
    .LINK
        https://learn.microsoft.com/dotnet/standard/serialization/binaryformatter-security-guide
#>
[CmdletBinding()]
param (
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
    $InputObject
)

begin {
    function Copy-Object {
        [CmdletBinding()]
        param (
                [Parameter(
                    Mandatory,
                    ValueFromPipeline
                )]
            $InputObject
        )

        process {
            $serializedObject = [Management.Automation.PSSerializer]::Serialize($InputObject)
            [Management.Automation.PSSerializer]::Deserialize($serializedObject)
        }
    }

    function Copy-Object2 {
        <#
            .NOTES
                The BinaryFormatter type is dangerous and is not recommended for data processing.
                Applications should stop using BinaryFormatter as soon as possible,
                even if they believe the data they're processing to be trustworthy.
                BinaryFormatter is insecure and can't be made secure.
            .LINK
                https://learn.microsoft.com/dotnet/standard/serialization/binaryformatter-security-guide
        #>
        [CmdletBinding()]
        param (
                [Parameter(
                    Mandatory,
                    ValueFromPipeline
                )]
            $InputObject
        )

        begin {
            $memStream = New-Object IO.MemoryStream
            $formatter = New-Object Runtime.Serialization.Formatters.Binary.BinaryFormatter
        }

        process {
            $formatter.Serialize($memStream, $InputObject)
            $memStream.Position = 0
            $formatter.Deserialize($memStream)
        }
    }

}

process {
    $InputObject | Copy-Object
}
