#Requires -Version 3
#Requires -Modules CimCmdlets
#Requires -RunAsAdministrator

<#
    .SYNOPSIS
        Reports shadow copy instances with additional information
    .DESCRIPTION
        This script reports shadow copy instances on server.
    .NOTES
        - ClientAccessible: If true, the shadow copy is created by the Windows Previous Versions component.
        - NoAutoRelease: If true, the shadow copy is retained after the requestor process ends.
          If false, the shadow copy is automatically deleted when the requestor process ends.
        - Persistent: The Persistent property indicates whether the shadow copy is persistent across reboots.
    .LINK
        https://docs.microsoft.com/previous-versions/windows/desktop/vsswmi/win32-shadowcopy
#>

Get-CimInstance -ClassName Win32_ShadowCopy | ForEach-Object {
    $volume = $_ | Get-CimAssociatedInstance -Association Win32_ShadowFor
    $Target = $_ | Get-CimAssociatedInstance -Association Win32_ShadowOn
    $Provider = $_ | Get-CimAssociatedInstance -Association Win32_ShadowBy
    [pscustomObject]@{
        Id               = $_.ID
        InstallDate      = $_.InstallDate
        Volume           = $volume.caption
        Target           = $Target.caption
        Provider         = $Provider.Name
        ClientAccessible = $_.ClientAccessible
        NoWriters        = $_.NoWriters
        Persistent       = $_.Persistent
        State            = $_.State
    }
}
