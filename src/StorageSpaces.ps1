#Requires -Modules Storage

<#
    .SYNOPSIS
        Shows how to create Storage Space and volume in Window 10 v2004 or newer
    .DESCRIPTION
        This is simple example how to crate Storage Space in Windows 10.

        The main reason to have such an example, is that in v2004, the GUI for
        creating Storage Space is broken and errors out.  At the same time, the
        PowerShell commands work without any problem
#>

[CmdletBinding()]
param (
    $PoolName = 'DiskPool',
    $DiskName = 'UserData',
    $DiskSize = 10GB,
    $SubSystem = 'windows*'
)

    # Add all available disks to new pool
$disks = Get-PhysicalDisk -CanPool $true
New-StoragePool -FriendlyName $PoolName -PhysicalDisks $disks -StorageSubSystemFriendlyName $SubSystem

    # Use pool's available space to create a virtual disk.
New-Volume -StoragePoolFriendlyName $PoolName -Size $DiskSize -FriendlyName $DiskName
Get-Volume -FriendlyName $DiskName |
    Get-Partition |
    Add-PartitionAccessPath -AssignDriveLetter

    # Format disk
Get-Volume -FriendlyName $DiskName | Format-Volume
