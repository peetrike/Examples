[CmdletBinding()]
param (
        [ValidateScript({
            test-path -Path $_ -PathType Leaf
        })]
        [string]
    $CredentialPath = (Join-Path -Path $PSScriptRoot -ChildPath 'credential.xml'),
    $OutPath = (Join-Path -Path $PSScriptRoot -ChildPath 'output.txt')
)

Write-Verbose -Message ('Using credential from: {0}' -f $CredentialPath)

$SavedCredential = Import-Clixml -Path $CredentialPath

add-content -Path $OutPath -Value 'Alustame'

add-content -Path $OutPath -Value $SavedCredential.UserName
add-content -Path $OutPath -Value $SavedCredential.GetNetworkCredential().Password
