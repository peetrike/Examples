﻿#Requires -Version 3

function New-EdgeApp {
    <#
        .SYNOPSIS
            Create Chrome Web Applications
        .DESCRIPTION
            This function creates web app shortcut in specified location
        .EXAMPLE
            New-EdgeApp -Name "web app" -URL https://peterwawa.wordpress.com -Target Desktop -SystemFolder

            Creates web app in user desktop for provided web site
        .NOTES
            Originally taken from: https://www.joseespitia.com/2020/11/03/new-chromewebapp-function/
        .LINK
            https://learn.microsoft.com/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/xsy6k3ys(v=vs.84)
    #>

    param (
            [Parameter(Mandatory)]
            [uri]
            # Specifies URL to use as web app
        $URL,
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [Alias('Destination')]
            [string]
            # Specifies location for the shortcut
        $Target,
            [Alias('System')]
            [switch]
            # Specifies that -Target contains SpecialFolder reference
            # (look at https://learn.microsoft.com/dotnet/api/system.environment.specialfolder)
        $SystemFolder,
            [ValidateNotNullOrEmpty()]
            [string]
            # Specifies shortcut name, if -Target points to folder
        $Name,
            [string]
            # Specify location for shortcut icon
        $Icon,
            [switch]
            # Pass the shortcut object to pipeline
        $PassThru
    )

    # Get MSEdge.exe path
    $EdgeCommand = (Get-ItemProperty -Path HKLM:\SOFTWARE\Classes\MSEdgeHTM\shell\open\command\).'(Default)'
    if ($EdgeCommand -match '"(.*)"') { $EdgePath = $Matches.1 }


    if ($SystemFolder) {
        $TargetPath = [Environment]::GetFolderPath($Target)
        if ($TargetPath -eq '') {
            throw [Management.Automation.ItemNotFoundException] (
                'There is no system path called {0}' -f $Target
            )
        }
    } elseif (Test-Path -Path $Target) {
        $TargetPath = (Resolve-Path -Path $Target).Path
    } elseif (Test-Path -Path (Split-Path -Path $Target)) {
        $TargetPath = $Target
    }

    if (Test-Path -Path $TargetPath -PathType Container) {
        $TargetPath = Join-Path -Path $TargetPath -ChildPath ($Name + '.lnk')
    }

    # Create web app shortcut
    $Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($TargetPath)
    $Shortcut.TargetPath = $EdgePath
    $Shortcut.Arguments = "--app=$URL"

    if ($Icon) {
        $Shortcut.IconLocation = $Icon
    }

    $Shortcut.Save()

    if ($PassThru) { $Shortcut }
}
