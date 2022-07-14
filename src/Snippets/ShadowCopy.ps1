#Requires -Version 3
#Requires -Modules CimCmdlets
#Requires -RunAsAdministrator

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
    }
}
