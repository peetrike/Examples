#Requires -Version 2.0

# [OutputType([String])]
[CmdletBinding()]
param (
        [parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [securestring]
    $SecureString
)

function Get-UnsecureString {
    # [OutputType([String])]
    [CmdletBinding()]
    param (
            [parameter(
                Mandatory = $true,
                ValueFromPipeline = $true
            )]
            [securestring]
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

Get-UnsecureString @PSBoundParameters
