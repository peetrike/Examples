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
    #>

    param (
            [Parameter(Mandatory)]
            [string]
            # Specifies shortcut name
        $Name,
            [Parameter(Mandatory)]
            [uri]
            # Specify URL to use as app
        $URL,
            [Parameter(Mandatory)]
            [Alias('Destination')]
            [string]
            # Specify location for the shortcut
        $Target,
            [Alias('System')]
            [switch]
            # Specifies that -Target contains SpecialFolder reference
            # (look at https://learn.microsoft.com/dotnet/api/system.environment.specialfolder)
        $SystemFolder,
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
    } else {
        $TargetPath = (Resolve-Path -Path $Target).Path
    }

    $TargetPath = Join-Path -Path $TargetPath -ChildPath ($Name + '.lnk')

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
