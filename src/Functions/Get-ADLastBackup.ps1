function Get-ADLastBackup {
    [CmdletBinding()]
    param (
            [string]
        $Domain,
            [ValidateNotNull()]
            [Management.Automation.PSCredential]
            [Management.Automation.Credential()]
        $Credential = [Management.Automation.PSCredential]::Empty
    )

    $DomainObject = if ($Domain) {
        $ContextProps = @(
            [DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain
            $Domain
        )
        if ($Credential -ne [Management.Automation.PSCredential]::Empty) {
            Write-Verbose -Message ('Authenticating as {1} to connect to {0}' -f $Domain, $Credential.UserName)
            $ContextProps += @(
                $Credential.UserName
                $Credential.GetNetworkCredential().Password
            )
        }
        $context = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $ContextProps
        [DirectoryServices.ActiveDirectory.Domain]::GetDomain($context)
    } else {
        [DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    }

    $DC = $DomainObject.FindDomainController()
    $RootDSE = [adsi] ('LDAP://{0}/RootDSE' -f $DomainObject.Name)
    $Context = $RootDSE.namingContexts | ForEach-Object { $_ }

    foreach ($ctx in $Context) {
        $dsaSignature = $DC.GetReplicationMetadata($ctx)['dsaSignature']
        [PSCustomObject] @{
            NamingContext = $ctx
            DC            = $DC.Name
            OriginatingDC = $dsaSignature.OriginatingServer
            LastBackup    = $dsaSignature.LastOriginatingChangeTime
        }
    }
}
