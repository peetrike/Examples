
function Get-DomainSid {
    [CmdletBinding()]
    [OutputType([Security.Principal.SecurityIdentifier])]
    param (
            [string]
        $Domain,
            [ValidateNotNull()]
            [pscredential]
            [Management.Automation.Credential()]
        $Credential
    )

    $DomainObject = if ($Domain) {
        $context = if ($Credential) {
            New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList @(
                [DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain,
                $Domain,
                $Credential.UserName,
                $Credential.GetNetworkCredential().Password
            )
        } else {
            New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList @(
                [DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain,
                $Domain
            )
        }
        [DirectoryServices.ActiveDirectory.Domain]::GetDomain($context)
    } else {
        [DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    }
    New-Object -TypeName Security.Principal.SecurityIdentifier -ArgumentList (
        $DomainObject.GetDirectoryEntry().objectSID[0],
        0
    )
}

Get-DomainSid
