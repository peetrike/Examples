#Requires -Version 3
#Requires -Modules CimCmdlets
#Requires -RunAsAdministrator

<#
    .SYNOPSIS
        contains functions that report Volume Shadow Copy service information
    .DESCRIPTION
        This script reports shadow copy instances on server.
    .NOTES
        - ClientAccessible: If true, the shadow copy is created by the Windows Previous Versions
          or System Restore component.
        - NoAutoRelease: If true, the shadow copy is retained after the requestor process ends.
          If false, the shadow copy is automatically deleted when the requestor process ends.
        - Persistent: The Persistent property indicates whether the shadow copy is persistent across reboots.
    .LINK
        https://docs.microsoft.com/previous-versions/windows/desktop/vsswmi/win32-shadowcopy
#>


function Get-ShadowCopy {
    [CmdletBinding()]
    param (
            [switch]
        $IncludeClientAccessible,
            [switch]
        $Oldest
    )

    $FilterParam = @{
        Filter = 'ClientAccessible=False'
    }
    if ($IncludeClientAccessible) {
        $FilterParam.Remove('Filter')
    }

    $Result = Get-CimInstance -ClassName Win32_ShadowCopy @FilterParam | ForEach-Object {
        $volume = $_ | Get-CimAssociatedInstance -Association Win32_ShadowFor
        $Target = $_ | Get-CimAssociatedInstance -Association Win32_ShadowOn
        $Provider = $_ | Get-CimAssociatedInstance -Association Win32_ShadowBy

        $OBjectProps = @{
            Id               = $_.ID
            CreationDate     = $_.InstallDate
            Volume           = $volume.caption
            Target           = $Target.caption
            Provider         = $Provider.Name
            #ProviderType     = $Provider.Type
            #ProviderVersion  = $Provider.Version
            NoAutoRelease    = $_.NoAutoRelease
            NoWriters        = $_.NoWriters
            Persistent       = $_.Persistent
            State            = $_.State
        }
        if ($IncludeClientAccessible) {
            $OBjectProps.ClientAccessible = $_.ClientAccessible
        }
        [pscustomObject] $OBjectProps
    }

    if ($Oldest) {
        $Result | Sort-Object CreationDate | Select-Object -First 1
    } else {
        $Result
    }
}

function Get-ShadowStorage {
    [CmdletBinding()]
    param (
            [switch]
        $HumanReadable
    )

    function Convert-Unit {
        [CmdletBinding()]
        param (
                [UInt64]
            $Value,
                [bool]
            $Convert
        )

        if ($Convert) {
            $Unit = switch ($Value) {
                { $_ -gt 1TB } { 1TB, 'TB' }
                { $_ -gt 1GB } { 1GB, 'GB' }
                { $_ -gt 1MB } { 1MB, 'MB' }
                { $_ -gt 1KB } { 1KB, 'KB' }
                default { 1, 'B'}
            }
                '{0} {1}' -f [math]::Round(($value / $Unit[0]), 2), $Unit[1]
        } else { $Value }
    }
    function Get-RelatedVolume {
        param (
            $Volume
        )

        $filter = 'DeviceId="{0}"' -f $Volume.DeviceId.Replace('\', '\\')
        Get-CimInstance -ClassName Win32_Volume -Filter $filter
    }

    Get-CimInstance -ClassName Win32_ShadowStorage | ForEach-Object {
        $Target = Get-RelatedVolume -Volume $_.DiffVolume
        $Volume = Get-RelatedVolume -Volume $_.Volume

        [pscustomObject] @{
            PSTypeName       = 'ShadowStorage'
            Source           = $Volume.Caption
            Target           = $Target.Caption
            TargetCapacity   = Convert-Unit -Convert:$HumanReadable -Value $Target.Capacity
            TargetFree       = Convert-Unit -Convert:$HumanReadable -Value $Target.FreeSpace
            StorageAllocated = Convert-Unit -Convert:$HumanReadable -Value $_.AllocatedSpace
            StorageMax       = Convert-Unit -Convert:$HumanReadable -Value $_.MaxSpace
            StorageUsed      = Convert-Unit -Convert:$HumanReadable -Value $_.UsedSpace
        }
    }
}
