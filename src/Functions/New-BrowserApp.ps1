#Requires -Version 3

function New-BrowserApp {
    <#
        .SYNOPSIS
            Create browser Web Applications
        .DESCRIPTION
            This function creates web app shortcut in specified location
        .EXAMPLE
            New-BrowserApp -Name "web app" -URL https://peterwawa.wordpress.com -Target Desktop -SystemFolder

            Creates web app in user desktop for provided web site
        .EXAMPLE
            New-BrowserApp -Name "web app" -URL https://peterwawa.wordpress.com -Target Desktop -SystemFolder -Browser Chrome

            Creates web app in user desktop for provided web site.  Use Google Chrome as browser.
        .INPUTS
            None
        .NOTES
            Originally taken from: https://www.joseespitia.com/2020/11/03/new-chromewebapp-function/
        .LINK
            https://learn.microsoft.com/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/xsy6k3ys(v=vs.84)
    #>

    [OutputType([void], [__ComObject])]
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
            [ValidateSet('Chrome', 'Edge')]
            [string]
            # Specifies browser used to create web app shortcut
        $Browser = 'Edge',
            [switch]
            # Pass the shortcut object to pipeline
        $PassThru
    )

    #region Determine Browser executable path
    $BrowserKey = @{
        Chrome = 'ChromeHTML'
        Edge   = 'MSEdgeHTM'
    }
    $BrowserRegKey = 'HKLM:\SOFTWARE\Classes\{0}\shell\open\command\' -f $BrowserKey.$Browser
    $BrowserCommand = (Get-ItemProperty -Path $BrowserRegKey).'(Default)'
    if ($BrowserCommand -match '"(.*)"') { $BrowserPath = $Matches.1 }

    if (-not (Test-Path -Path $BrowserPath -PathType Leaf)) {
        Write-Error -Message ('Chosen browser ({0}) path not found' -f $Browser) -ErrorAction Stop
    }
    #endregion

    #region Determine shortcut target path
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
    #endregion

    #region Create web app shortcut
    $Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($TargetPath)
    $Shortcut.TargetPath = $BrowserPath
    $Shortcut.Arguments = "--app=$URL"

    if ($Icon) {
        $Shortcut.IconLocation = $Icon
    }

    $Shortcut.Save()
    #endregion

    if ($PassThru) { $Shortcut }
}
