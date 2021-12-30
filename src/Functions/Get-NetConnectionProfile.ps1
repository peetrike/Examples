try {
    $null = [Telia.NetworkCategory]
} catch {
    add-type -TypeDefinition @'
        namespace Telia {
            public enum NetworkCategory {
                Public,
                Private,
                DomainAuthenticated
            }

        }
'@
            <# public enum DomainType {
                NonDomain,
                DomainConnected,
                DomainAuthenticated
            } #>
}

# for Vista/Win7
function Get-NetConnectionProfile {
    [CmdletBinding()]
    param (
            [Telia.NetworkCategory]
        $NetworkCategory
    )

    begin {
        $NLMType = [Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B')
        $networkListManager = [Activator]::CreateInstance($NLMType)
    }

    process {
        foreach ($Connection in $networkListManager.GetNetworkConnections()) {
            $Result = $Connection.GetNetwork()
            $NetCategory = $Result.GetCategory()
            if (($null -eq $NetworkCategory) -or ($NetworkCategory -eq $NetCategory)) {
                #$NetworkId = $Result.GetNetworkId()
                #$AdapterId = $Connection.GetAdapterId()
                $ConnectionProps = @{
                    NetworkCategory = [Telia.NetworkCategory] $NetCategory
                    #Connectivity = $Result.GetConnectivity()
                    #Description = $Result.GetDescription()  # same as Name
                    #DomainType = [Telia.DomainType] $Result.GetDomainType()
                    IsConnected     = $Result.IsConnected
                    Name            = $Result.GetName()
                }
                New-Object -TypeName PsCustomObject -Property $ConnectionProps
            }
        }
    }
}
