
function Get-DomainSid {
    [CmdletBinding(
        DefaultParameterSetName = 'Custom'
    )]
    [OutputType([Security.Principal.SecurityIdentifier])]
    param (
            [Parameter(
                ParameterSetName = 'Computer'
            )]
            [switch]
        $Computer,
            [Parameter(
                ParameterSetName = 'Custom'
            )]
            [string]
        $Domain,
            [Parameter(
                ParameterSetName = 'Custom'
            )]
            [ValidateNotNull()]
            [Management.Automation.PSCredential]
            [Management.Automation.Credential()]
        $Credential = [Management.Automation.PSCredential]::Empty
    )

    $DomainObject = if ($Computer) {
        Write-Verbose -Message 'Using computer domain'
        [DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()
    } elseif ($Domain) {
        $context = if ($Credential -ne [Management.Automation.PSCredential]::Empty) {
            Write-Verbose -Message ('Authenticating as {1} to connect to {0}' -f $Domain, $Credential.UserName)
            New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList @(
                [DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain,
                $Domain,
                $Credential.UserName,
                $Credential.GetNetworkCredential().Password
            )
        } else {
            Write-Verbose -Message ('Using current credentials to connect to {0}' -f $Domain)
            New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList @(
                [DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain,
                $Domain
            )
        }
        [DirectoryServices.ActiveDirectory.Domain]::GetDomain($context)
    } else {
        Write-Verbose -Message 'Using current user domain'
        [DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    }
    New-Object -TypeName Security.Principal.SecurityIdentifier -ArgumentList (
        $DomainObject.GetDirectoryEntry().objectSID[0],
        0
    )
}

Get-DomainSid
