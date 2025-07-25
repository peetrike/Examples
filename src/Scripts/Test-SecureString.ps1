[CmdletBinding()]
param (
        [string]
    $String,
        [securestring]
    $SecureString
)

function Get-UnsecureString {
    [OutputType([String])]
    [CmdletBinding()]
    param (
            [parameter(
                Mandatory = $true,
                ValueFromPipeline = $true
            )]
            [Security.SecureString]
        $SecureString
    )

    process {
        $BinaryString = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString);

        try {
            [Runtime.InteropServices.Marshal]::PtrToStringBSTR($BinaryString)
        } finally {
            [Runtime.InteropServices.Marshal]::FreeBSTR($BinaryString)
        }
    }
}

$StringSecure = ConvertTo-SecureString -String $String -AsPlainText -Force
Get-UnsecureString -SecureString $StringSecure
Get-UnsecureString -SecureString $SecureString
