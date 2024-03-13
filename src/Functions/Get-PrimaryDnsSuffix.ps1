function Get-PrimaryDnsSuffix {
    <#
        .LINK
            https://learn.microsoft.com/windows/win32/sysinfo/computer-names
    #>
    [OutputType([string])]
	param ()

	# https://learn.microsoft.com/dotnet/api/system.net.networkinformation.ipglobalproperties
    [Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().DomainName
}
