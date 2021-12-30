#Requires -Modules ScheduledTasks

Function New-ScheduledTaskFolder {
    <#
        .SYNOPSIS
        Creates new folder in Task Scheduler.

        .DESCRIPTION
        Add a more complete description of what the function does.

        .PARAMETER TaskPath
        The path of new foler.

        .EXAMPLE
        New-ScheduledTaskFolder -TaskPath "MyFolder"
        Creates a new folder in task scheduler, called \MyFolder

        .NOTES
        Borrowed from Ed Wilson.

        .LINK
        schedule.service COM object: https://msdn.microsoft.com/en-us/library/windows/desktop/aa383607(v=vs.85).aspx

        .INPUTS
        List of input types that are accepted by this function.
    #>

    Param (
            [Parameter(Mandatory = $true)]
            [string]
        $TaskPath
    )

    $ErrorActionPreference = 'stop'

    $scheduleObject = New-Object -ComObject schedule.service
    $scheduleObject.connect()
    $rootFolder = $scheduleObject.GetFolder('\')

    Try {
        $null = $scheduleObject.GetFolder($taskpath)
    } Catch {
        $null = $rootFolder.CreateFolder($taskpath)
    }

    $ErrorActionPreference = 'continue'
}

$minukaust = '\Meelis\'

Get-ScheduledTask
New-ScheduledTaskFolder -TaskPath 'Meelis'
Get-ScheduledTask -TaskPath $minukaust

$töö = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-command "dir"'
$trigger = New-ScheduledTaskTrigger -AtLogOn
help New-ScheduledTaskPrincipal -ShowWindow

#Requires -RunAsAdministrator
Register-ScheduledTask -TaskName 'test4' -TaskPath $minukaust -Action $töö -Trigger $trigger -Description 'miski kirjeldus' # -RunLevel Limited
#region new
$task = New-ScheduledTask -Action $töö -Trigger $trigger -Description 'miski teine kirjeldus'
$task | Register-ScheduledTask -TaskName 'test3' -TaskPath $minukaust
#endregion

help New-ScheduledTask -ShowWindow
help Register-ScheduledTask -ShowWindow

Get-ScheduledTask -TaskName test2 | Disable-ScheduledTask
