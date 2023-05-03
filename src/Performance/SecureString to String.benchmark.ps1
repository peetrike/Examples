#Requires -Modules benchpress

$SecureString = ConvertTo-SecureString -String 'ThisispA$sw0rd' -AsPlainText -Force

function ConvertTo-String2 {
    [OutputType([string])]
    param (
            [securestring]
        $SecureString
    )

    [Net.NetworkCredential]::new('', $SecureString).Password
}

function ConvertTo-String {
    [OutputType([string])]
    param (
            [securestring]
        $SecureString
    )

    $BinaryString = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)

    try {
        [Runtime.InteropServices.Marshal]::PtrToStringBSTR($BinaryString)
    } finally {
        [Runtime.InteropServices.Marshal]::FreeBSTR($BinaryString)
    }
}

$Technique = @{
    'Interop'           = {
        ConvertTo-String $SecureString
    }
    'NetworkCredential' = {
        ConvertTo-String2 $SecureString
    }
}

if ($PSVersionTable.PSVersion.Major -ge 7) {
    $Technique += @{
        'cmdlet' = {
            ConvertFrom-SecureString $SecureString -AsPlainText
        }
    }
}

Measure-Benchmark -Technique $Technique -RepeatCount 10000
