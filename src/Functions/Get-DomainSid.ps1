
function Get-DomainSid {
    [CmdletBinding()]
    [OutputType([Security.Principal.SecurityIdentifier])]
    param ()
    $Domain = [DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    New-Object -TypeName Security.Principal.SecurityIdentifier -ArgumentList (
        $Domain.GetDirectoryEntry().objectSID[0],
        0
    )
}

Get-DomainSid
