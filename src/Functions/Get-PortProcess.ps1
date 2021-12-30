#Requires -Version 3.0
#Requires -Modules NetTCPIP

[CmdletBinding()]
param (
        [ValidateSet('TCP', 'UDP')]
        [string[]]
    $Protocol = @('TCP', 'UDP'),
        [uint16[]]
    $Port
)

function Get-PortProcess {
    [CmdletBinding()]
    param (
            [ValidateSet('TCP', 'UDP')]
            [string[]]
        $Protocol = @('TCP', 'UDP'),
            [uint16[]]
        $Port
    )

    function Get-PortOwner {
        param (
                [ValidateSet('TCP', 'UDP')]
                [string]
            $Protocol,
                [parameter(
                    ValueFromPipeline
                )]
            $InputObject,
                [Microsoft.Management.Infrastructure.CimInstance[]]
            $ServiceCollection
        )

        process {
            $process = Get-Process -Id $InputObject.OwningProcess
            $ObjectProperties = [ordered] @{
                Protocol = $Protocol
                #IP       = $InputObject.LocalAddress
                Port     = $InputObject.LocalPort
                Process  = $process.Id
                Name     = $process.Name
                Path     = $process.Path
            }
            if (-not $process.Path) {
                $service = @($ServiceCollection | Where-Object ProcessId -EQ $_.OwningProcess)
                if ($service.count -gt 0) {
                    $ObjectProperties.Name = $service.Name
                }
                $ObjectProperties.Path = $service | Select-Object -First 1 -ExpandProperty PathName
            }
            [PSCustomObject] $ObjectProperties
        }
    }

    $ServiceCollection = Get-CimInstance -ClassName Win32_Service -Property Name, PathName, ProcessId -Verbose:$false
    $connectionProps = @{
        ErrorAction = 'SilentlyContinue'
        State       = 'Listen'
    }
    if ($Port) {
        $connectionProps.LocalPort = $Port
    }
    if ($Protocol -contains 'TCP') {
        Get-NetTCPConnection @connectionProps |
            Sort-Object -Property LocalPort -Unique | # to get rid of IPv4/IPv6 and multi-nic duplicates
            Get-PortOwner -Protocol 'TCP' -ServiceCollection $ServiceCollection
    }
    if ($Protocol -contains 'UDP') {
        $connectionProps.Remove('State')
        Get-NetUDPEndpoint @connectionProps |
            Sort-Object -Property LocalPort -Unique | # to get rid of IPv4/IPv6 and multi-nic duplicates
            Get-PortOwner -Protocol 'UDP' -ServiceCollection $ServiceCollection
    }
}

Get-PortProcess @PSBoundParameters
