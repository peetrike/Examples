function Get-PrimaryDnsSuffix {
    <#
        .LINK
            https://learn.microsoft.com/dotnet/api/system.net.networkinformation.ipglobalproperties
    #>
    [OutputType([string])]
    param ()

    [Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().DomainName
}
