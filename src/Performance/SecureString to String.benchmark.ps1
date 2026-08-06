#Requires -Version 2.0
# Requires -Modules benchpress

function NetworkCredential {
    [OutputType([string])]
    param (
            [Security.SecureString]
        $SecureString
    )

    $credential = new-object System.Net.NetworkCredential -ArgumentList @(
        'user'
        $SecureString
    )
    $credential.Password
}

function Credential {
    [OutputType([string])]
    param (
            [Security.SecureString]
        $SecureString
    )

    $Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @(
        'user'
        $SecureString
    )
    $Cred.GetNetworkCredential().Password
}

function ConvertTo-String {
    [OutputType([string])]
    param (
            [Security.SecureString]
        $SecureString
    )

    $BinaryString = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)

    try {
        [Runtime.InteropServices.Marshal]::PtrToStringBSTR($BinaryString)
    } finally {
        [Runtime.InteropServices.Marshal]::FreeBSTR($BinaryString)
    }
}

$SecureString = ConvertTo-SecureString -String 'ThisispA$sw0rd' -AsPlainText -Force

$Technique = @{
    'Interop'    = {
        ConvertTo-String $SecureString
    }
    'Credential' = {
        Credential $SecureString
    }
}


if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique += @{
        'NetworkCredential' = {
            NetworkCredential $SecureString
        }
    }

    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $Technique += @{
            'cmdlet' = {
                ConvertFrom-SecureString $SecureString -AsPlainText
            }
        }
    }
} else {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1
}

Measure-Benchmark -Technique $Technique -RepeatCount 10000
