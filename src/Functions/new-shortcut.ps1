#Requires -version 2.0

<#PSScriptInfo
    .VERSION 1.1.0
#>

<#
    .SYNOPSIS
        Creates a shortcut from input object.
    .DESCRIPTION
        This function creates a shortcut from object coming from pipeline
    .EXAMPLE
        Get-ChildItem -Path "$env:ProgramFiles\MyApp" -Filter *.exe | New-Shortcut -Target .

        This example creates shortcuts to current working directory for every .exe
        file discovered by Get-ChildItem.
    .EXAMPLE
        New-Shortcut -Url http://www.ee -Target Personal -SystemFolder

        This example creates .url shortcut to current user's Desktop
    .EXAMPLE
        New-Shortcut -File cmd.exe -Target 25 -SystemFolder

        This example creates shortcut for cmd.exe in CommonDesktopDirectory known folder
    .INPUTS
        System.IO.DirInfo, System.IO.FileInfo, System.Uri
    .OUTPUTS
        System.__ComObject#{f935dc23-1cf0-11d0-adb9-00c04fd58a0b}
    .LINK
        https://docs.microsoft.com/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/xsy6k3ys(v=vs.84)
#>

#function new-shortcut {

    [CmdletBinding(
        DefaultParameterSetName='File',
        SupportsShouldProcess=$True
    )]
    #[OutputType([System.__ComObject#{f935dc23-1cf0-11d0-adb9-00c04fd58a0b}])]
    param(
            [Parameter(
                Position=0,
                ValueFromPipeline=$true,
                Mandatory=$true,
                ParameterSetName='File'
            )]
            [ValidateNotNull()]
            [Alias('file')]
            [IO.FileInfo]
            # Specifies file(s) to make shortcut(s) from.  As an alternate, this could also be
            # program name from Path
        $FileItem,
            [Parameter(
                Position=0,
                ValueFromPipeline=$true,
                Mandatory=$true,
                ParameterSetName='Dir'
            )]
            [ValidateNotNull()]
            [Alias('dir')]
            [IO.DirectoryInfo]
            # Specifies folder(s) to make shortcut(s) from
        $DirItem,
            [Parameter(
                Position=0,
                ValueFromPipeline=$true,
                Mandatory=$true,
                ParameterSetName='Url'
            )]
            [ValidateNotNullOrEmpty()]
            [Alias('url')]
            [uri]
            # Specifies URI for shortcut
        $UrlItem,
            [Parameter(
                Position=1,
                Mandatory=$true,
                ParameterSetName='Url'
            )]
            [Parameter(
                Position=1,
                Mandatory=$true,
                ParameterSetName='Dir'
            )]
            [Parameter(
                Position=1,
                Mandatory=$true,
                ParameterSetName='File'
            )]
            [ValidateNotNullOrEmpty()]
            [Alias('Destination')]
            [String]
            # Specifies folder where shortcut should be created
        $Target,
            [Parameter(
                ParameterSetName='Url'
            )]
            [Parameter(
                ParameterSetName='Dir'
            )]
            [Parameter(
                ParameterSetName='File'
            )]
            [Alias('System')]
            [switch]
            # Specifies that -Target contains SpecialFolder reference
            # (look at https://docs.microsoft.com/dotnet/api/system.environment.specialfolder)
        $SystemFolder,
            [Parameter(
                ParameterSetName='Url'
            )]
            [Parameter(
                ParameterSetName='Dir'
            )]
            [Parameter(
                ParameterSetName='File'
            )]
            [switch]
        $Force,
            [Parameter(
                ParameterSetName='Url'
            )]
            [Parameter(
                ParameterSetName='Dir'
            )]
            [Parameter(
                ParameterSetName='File'
            )]
            [switch]
            # Pass the created shortcut object down the pipeline
        $PassThru,
            [Parameter(
                Mandatory = $true,
                ParameterSetName = 'Version',
                Position = 0
            )]
            [Alias('v')]
            [switch]
            # Show the script version number
        $Version
    )

    begin {
        if ($PSCmdlet.ParameterSetName -like 'Version') {
                # Script version
            try {
                $VersionInfo = (Test-ScriptFileInfo -Path $PSCommandPath -ErrorAction Stop).Version
            } catch {
                Write-Verbose -Message 'Test-ScriptFileInfo failed, reverting to regular expression search'
                $result = Select-String -Path $MyInvocation.MyCommand.Path -Pattern '^\s*\.VERSION (\d+(\.\d+){0,3})$'
                $VersionInfo = ($result.Matches | Select-Object -ExpandProperty Groups)[1].Value
            }

            return ([version] $VersionInfo)
        }

        $shortcutSettings = @{}
        if ($SystemFolder.IsPresent) {
            $shortcutSettings.Path = [Environment]::GetFolderPath($Target)
            if ($shortcutSettings.Path -eq '') {
                throw [Management.Automation.ItemNotFoundException](
                    'There is no system path called {0}' -f $Target
                )
            }
        } else {
            $shortcutSettings.Path = (Resolve-Path -Path $Target).Path
        }
        Write-Verbose -Message ('shortcut will be saved to {0}' -f $shortcutSettings.Path)

        $yesToAll = $false
        $noToAll = $false
        $WshShell = New-Object -ComObject WScript.Shell
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Dir' {
                $shortcutSettings.TargetPath = $DirItem.FullName
                $shortcutSettings.Name = $DirItem.BaseName + '.lnk'
            }
            'File' {
                if (Test-Path -Path $FileItem.FullName) {
                    $shortcutSettings.TargetPath = $FileItem.FullName
                    $shortcutSettings.Name = $FileItem.BaseName + '.lnk'
                } elseif ($command = Get-Command -Name $FileItem.name -CommandType Application -ErrorAction Stop) {
                    $shortcutSettings.TargetPath = $command.Path
                    $shortcutSettings.Name = $command.Name + '.lnk'
                }
            }
            'Url' {
                $shortcutSettings.TargetPath = $UrlItem.AbsoluteUri
                $shortcutSettings.Name = $UrlItem.Authority + '.url'
            }
            'Version' {
                return
            }
        }

        $shortcutPath = Join-Path $shortcutSettings.Path $shortcutSettings.Name

        if ($PSCmdLet.ShouldProcess($shortcutPath, 'Create shortcut')) {
            $mustdo = $false
            if (Test-Path $shortcutPath -PathType Leaf) {
                if ($Force -or $PSCmdlet.ShouldContinue(
                        'Overwrite?',
                        $('{0} already exists.' -f $shortcutPath),
                        [ref] $yesToAll,
                        [ref] $noToAll
                    )
                ) { $mustdo = $true }
            } else {
                $mustdo = $true
            }

            if ($mustdo) {
                Write-Verbose ('Creating shortcut: {0}' -f $shortcutSettings.Name)

                $shortcut = $WshShell.CreateShortcut($shortcutPath)
                $shortcut.TargetPath = $shortcutSettings.TargetPath
                $shortcut.Save()

                if ($PassThru) {
                    $shortcut
                }
            }
        }
    }
#}
