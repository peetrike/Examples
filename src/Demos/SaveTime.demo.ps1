<#
    .SYNOPSIS
        Save time with PowerShell demo
    .DESCRIPTION
        This file contains demo transcript about
        * How to make Powershell working environment more enjoyable
        * Why should You follow "filter left" principle
        * How to convert data to more suitable data type
    .NOTES
        Contact: Meelis Nigols
        e-mail/skype: meelisn@outlook.com
    .LINK
        https://github.com/peetrike/examples
#>

#region Safety to prevent the entire script from being run instead of a selection
throw "You're not supposed to run the entire script"
#endregion

#region Work environment
    #region Fonts
        # https://github.com/microsoft/cascadia-code
        # https://github.com/PowerLine/fonts
        # https://programmingfonts.org
        # https://www.nerdfonts.com/
    #endregion

    #region Editor
        # https://code.visualstudio.com
        # https://code.visualstudio.com/docs/languages/powershell
        # https://docs.microsoft.com/powershell/scripting/dev-cross-plat/vscode/using-vscode
    #endregion

    #region Terminal app
        # https://docs.microsoft.com/windows/terminal/

        winget.exe show Microsoft.WindowsTerminal
        Get-Command -Name wt -CommandType Application

        wt.exe -?
        # https://docs.microsoft.com/windows/terminal/command-line-arguments?tabs=powershell
    #endregion

    #region Prompt
        Get-Item function:/prompt
        # https://ohmyposh.dev
        # https://starship.rs

        Find-Module PowerLine -Repository PSGallery
        Find-Module -Tag prompt -Repository PSGallery
    #endregion

    #region command output
            # Requires -Version 7.2
        Get-Help ANSI_Terminals -ShowWindow

        $PSStyle.OutputRendering
        Get-Process pwsh
        $PSStyle.OutputRendering = [Management.Automation.OutputRendering]::PlainText
        Get-Process pwsh
        $PSStyle.OutputRendering = [Management.Automation.OutputRendering]::Host

        #region Text-based User Interface
                # Requires -Modules Microsoft.PowerShell.ConsoleGuiTools
            Get-ChildItem | Out-ConsoleGridView -OutputMode Multiple

            # https://blog.ironmansoftware.com/tui-powershell
            # https://gui-cs.github.io/Terminal.Gui
        #endregion

        #region Colorize directory content output
            $PSStyle.FileInfo
            $PSStyle.FileInfo.Extension.Keys
            $PSStyle.FileInfo.Extension['.zip']

            Get-ExperimentalFeature PSAnsiRenderingFileInfo
            Enable-ExperimentalFeature PSAnsiRenderingFileInfo
            Get-ChildItem
            Disable-ExperimentalFeature PSAnsiRenderingFileInfo

                # alternate approach - requires one of Nerd Fonts
            Find-Module terminal-icons -Repository PSGallery
            Import-Module terminal-icons
            Get-ChildItem
            Remove-Module terminal-icons
        #endregion

    #endregion

    #region PSReadLine module usage
        #region Predictive history
            # https://devblogs.microsoft.com/powershell/psreadline-2-2-ga/
            # https://docs.microsoft.com/powershell/module/psreadline/about/about_psreadline?view=powershell-7.2#predictive-intellisense
        #endregion

        #region KeyBindings
            Get-PSReadLineKeyHandler -Chord Ctrl+RightArrow
            Get-PSReadLineKeyHandler

            Get-Help Set-PSReadLineKeyHandler -ShowWindow
        #endregion

    #endregion
#endregion

#region Optimizing filtering performance
    # https://docs.microsoft.com/powershell/scripting/learn/ps101/04-pipelines#filtering-left

    Get-ADUser -Identity adam
    Measure-Command {
        Get-ADUser -Identity adam
    }
    Measure-Command {
        Get-ADUser -Filter { Name -like 'Adam*' }
    }
    Measure-Command {
        Get-ADUser -LDAPFilter '(Name=Adam*)'
    }

    Measure-Command {
        Get-ADUser -Filter * | Where-Object Name -like 'Adam*'
    }

    Measure-Command {
        Get-ADUser -Filter * -Properties * | Where-Object Name -like 'Adam*'
    }
    Measure-Command {
        Get-ADObject -Filter * -Properties * | Where-Object Name -like 'Adam*'
    }

        # negatiivne näide ka
    Get-ScheduledTask -TaskName katse
    Get-ScheduledTask -TaskName katse | Get-Member

    $CimOptions = @{
        Namespace = 'Root/Microsoft/Windows/TaskScheduler'
        Filter    = 'TaskName="katse"'
    }
    Get-CimInstance MSFT_ScheduledTask @CimOptions

    Measure-Command {
        Get-CimInstance MSFT_ScheduledTask @CimOptions
    }
    Measure-Command {
        Get-ScheduledTask -TaskName katse
    }

    Measure-Command {
        Get-ScheduledTask -TaskName katse -TaskPath '\meelis\'
    }
    Measure-Command {
        Get-ScheduledTask | Where-Object TaskName -eq 'katse'
    }

    #region import function
    function Get-TaskInfo {
        <#
            .SYNOPSIS
                Finds Scheduled tasks from local computer
            .DESCRIPTION
                This sample function searches for Scheduled Tasks on local computer
            .LINK
                https://docs.microsoft.com/windows/win32/taskschd/task-scheduler-start-page
        #>

        [CmdletBinding()]
        param(
                [ValidateNotNullOrEmpty()]
                [string]
                # Specifies Scheduled Task name search pattern
            $TaskName = '*',
                [string]
                # Specifies path for scheduled tasks in Task Scheduler namespace.
            $TaskPath
        )

        function Get-TaskFolder {
            [CmdletBinding()]
            param (
                $Folder
            )
            $Folder
            foreach ($subFolder in $Folder.GetFolders(0)) {
                Get-TaskFolder -Folder $subFolder
            }
        }

        function Get-Task {
            param (
                    [string]
                $Name = '*',
                $Folder
            )

            if ($Name -and $Name -notmatch '\*') {
                try {
                    $Folder.GetTask($Name)
                } catch {
                    Write-Verbose -Message ('No tasks in folder {0}' -f $Folder.Path)
                }
            } else {
                    # include hidden tasks
                $Folder.GetTasks(1) | Where-Object { $_.Name -like $Name }
            }
        }

        $Scheduler = New-Object -ComObject 'Schedule.Service'
        $Scheduler.Connect()
        $RootFolder = $Scheduler.GetFolder('\')

        if ($TaskName -match '\\') {
            $RootFolder.GetTask($TaskName)
        } elseif ($TaskPath) {
            $currentFolder = $RootFolder.GetFolder($TaskPath.TrimEnd('\'))
            Get-Task -Name $TaskName -Folder $currentFolder
        } else {
            foreach ($folder in Get-TaskFolder -Folder $RootFolder) {
                Get-Task -Name $TaskName -Folder $folder
            }
        }
    }
    #endregion

    Measure-Command {
        Get-TaskInfo -TaskName meelis\katse
    }
    Measure-Command {
        Get-TaskInfo -TaskName katse -TaskPath meelis
    }
    Measure-Command {
        Get-TaskInfo -TaskName katse
    }
    Measure-Command {
        Get-TaskInfo | Where-Object Name -eq 'katse'
    }

#endregion

#region List of AD computers by OS version
    Get-ADComputer -Identity $env:COMPUTERNAME -Properties * | Get-Member -Name Operating*

    $PropertyList = 'OperatingSystemVersion', 'OperatingSystem'

    Get-ADComputer -Identity $env:COMPUTERNAME -Properties $PropertyList

    Get-ADComputer -Filter { OperatingSystemVersion -like '5.*' } | Measure-Object
    Get-ADComputer -Filter { OperatingSystemVersion -like '*(20348)' } | Measure-Object
    Get-ADComputer -Filter { OperatingSystem -like 'Windows 11*' } -Properties $PropertyList |
        Select-Object Name, Operating*

    #region Generate report by version
        $VersionSample = (Get-ADComputer -Identity Lon-DC1 -Properties $PropertyList).OperatingSystemVersion
        $VersionSample

            # sort by OS version Major, Minor
        $VersionSample.Split(' ')
        Get-ADComputer -Filter { OperatingSystem -like 'Windows*' } -Properties $PropertyList |
            Sort-Object -Property { [version] $_.OperatingSystemVersion.Split(' ')[0] }

            # sort by OS version Build number
        $VersionSample.Split('(')
        $VersionSample.Split('(')[-1]
        $VersionSample.Split('(')[-1].TrimEnd(')')
        Get-ADComputer -Filter { OperatingSystem -like 'Windows*' } -Properties $PropertyList |
            Sort-Object -Property { [int] $_.OperatingSystemVersion.Split('(')[1].TrimEnd(')') }

            # convert version string to [System.Version] object
        $VersionSample -replace '(\d+\.\d+) \((\d+)\)', '$1.$2'
        [version] ($VersionSample -replace '(\d+\.\d+) \((\d+)\)', '$1.$2')
        $osVersion = @{
            Name       = 'OsVersion'
            Expression = { [version] ($_.OperatingSystemVersion -replace '(\d+\.\d+) \((\d+)\)', '$1.$2') }
        }

        Get-ADComputer -Filter { OperatingSystem -like 'Windows*' } -Properties $PropertyList |
            Select-Object Name, OperatingSystem, $osVersion

        Get-ADComputer -Filter { OperatingSystem -like 'Windows*' } -Properties $PropertyList |
            Sort-Object -Property $osVersion.Expression

        Get-ADComputer -Filter { OperatingSystem -like 'Windows*' } -Properties $PropertyList |
            Group-Object -Property $osVersion.Expression -NoElement |
            Sort-Object -Property Count -Descending
    #endregion

#endregion
