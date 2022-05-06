<#
    .SYNOPSIS
        Windows event log processing demo
    .DESCRIPTION
        This file contains demo transcript from
        Windows Event log processing demo
    .NOTES
        Contact: Meelis Nigols
        e-mail/skype: meelisn@outlook.com
    .LINK
        https://github.com/peetrike/examples
    .LINK
        https://peterwawa.wordpress.com/tag/log/
    .LINK
        https://docs.microsoft.com/powershell/scripting/samples/creating-get-winevent-queries-with-filterhashtable
#>

#region Safety to prevent the entire script from being run instead of a selection
    throw "You're not supposed to run the entire script"
#endregion

#region Getting access to event log

Get-Command -noun WinEvent
    # not available in PowerShell 6+
Get-Command -noun EventLog

Get-Help Get-EventLog

#endregion

#region Using Get-EventLog

Get-Help Get-EventLog -ShowWindow
Get-Help Get-EventLog -Examples

    # look at the note
(Get-Help Get-EventLog).Description

    # find the available logs
Get-EventLog -List

    # search from log
Get-EventLog -LogName Application -Newest 10
Get-EventLog -LogName Application -Newest 10 | Get-Member

Get-EventLog -LogName Application -Source Outlook -Newest 10

Get-EventLog -LogName Application -Source Outlook -Newest 10 |
    Where-Object EventId -EQ 63

#endregion

#region Get-WinEvent simple queries

Get-Help Get-WinEvent -ShowWindow
Get-Help Get-WinEvent -Examples

#region Discover logs and providers

Get-WinEvent -ListLog *powershell*
Get-WinEvent -ListProvider out*

Get-WinEvent -ListLog Application | Format-List *
Get-WinEvent -ListLog Application | Get-Member

#endregion

Get-WinEvent -LogName Application -MaxEvents 10
Get-WinEvent -ProviderName Outlook -MaxEvents 10

#endregion

#region Using FilterHashTable

Get-Help Get-WinEvent -Parameter FilterHashTable

Get-WinEvent -FilterHashtable @{
    LogName = 'Application'
    Level   = 2  # error
} -MaxEvents 10

$level = [Diagnostics.Eventing.Reader.StandardEventLevel]::Warning
Get-WinEvent -FilterHashtable @{
    LogName = 'Application'
    Level   = [int] $level
} -MaxEvents 10

Get-WinEvent -FilterHashtable @{
    LogName = 'Application'
    Id      = 63
} -MaxEvents 10

Get-WinEvent -FilterHashtable @{
    ProviderName = 'Outlook'
    Id           = 63
} -MaxEvents 10

#Requires -RunAsAdministrator
Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4624
    StartTime = [datetime]::Now.AddHours(-1)
} -MaxEvents 10

Get-WinEvent -FilterHashtable @{
    LogName      = 'Application'
    ProviderName = 'Application Error'
    Data         = 'vmconnect.exe'  # data from message body
}

$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent().User
Get-WinEvent -FilterHashtable @{
    LogName = 'Application'
    UserID  = $CurrentUser
} -MaxEvents 5

#endregion

#region Extracting properties from event

$MyEvent = Get-WinEvent -FilterHashtable @{
    ProviderName = 'Service Control Manager'
    ID           = 7040  # service start type was changed
} -MaxEvents 1

$MyEvent | Get-Member
# https://docs.microsoft.com/dotnet/api/System.Diagnostics.Eventing.Reader.EventLogRecord

$MyEvent | Format-List *
$MyEvent.Message

$MyEvent.Properties
$MyEvent.Properties[0]  # Service display name
$MyEvent.Properties[3]  # Service short name

# https://github.com/peetrike/scripts/blob/master/src/ActiveDirectory/ADFS/Get-AdfsAuditEvent516.ps1
# https://github.com/peetrike/scripts/blob/master/src/Filesystem/Get-EventReport.ps1

#region Using named properties

eventvwr.exe

$MyEvent = Get-WinEvent -FilterHashtable @{
    ProviderName = 'Microsoft-Windows-DNS-Client'
    Id           = 8018
} -MaxEvents 1

$MyEvent.Properties

    # asking for specific named parameters
[string[]] $xPathRefs = @(
    'Event/System/Security/@UserID'
    'Event/System/TimeCreated/@SystemTime'
    'Event/System/EventID'
    'Event/EventData/Data[@Name="HostName"]'
)
[Collections.Generic.IEnumerable[string]] $xPathEnum = $xPathRefs
$LogPropertyContext = [Diagnostics.Eventing.Reader.EventLogPropertySelector]::new($xPathEnum)
$MyEvent.GetPropertyValues($LogPropertyContext)

    # Obtaining event XLM form
$EventXml = [xml] $MyEvent.ToXml()

$EventXml.GetType()
$EventXml | Get-Member
$EventXml
$EventXml.Event
$EventXml.Event.System
$EventXml.Event.System.TimeCreated
$EventXml.Event.System.TimeCreated.SystemTime
$MyEvent.TimeCreated

$EventXml.Event.EventData
$EventXml.Event.EventData.Data
$EventXml.Event.EventData.Data | Where-Object Name -like 'HostName'
$EventXml.Event.EventData.Data | Where-Object Name -like 'HostName' | Get-Member -Force
($EventXml.Event.EventData.Data | Where-Object Name -like 'HostName').'#text'
($EventXml.Event.EventData.Data | Where-Object Name -like 'HostName').InnerText

    # https://docs.microsoft.com/et-ee/windows/win32/wes/consuming-events
    # https://www.w3.org/TR/xpath/
$EventXml | Get-Member -name Select*
$EventXml.SelectSingleNode('//*[@Name = "HostName"]')
$EventXml.SelectSingleNode('//*[@Name = "HostName"]').InnerText

    # speed difference
Measure-Command { ($EventXml.Event.EventData.Data | Where-Object Name -like 'HostName').InnerText }
Measure-Command { $EventXml.SelectSingleNode('//*[@Name = "HostName"]').InnerText }

# https://github.com/peetrike/Examples/blob/main/src/Snippets/Get-DnsClientEvent.ps1

#endregion


#endregion

#region Using XPath filtering during search

eventvwr.exe

#Requires -RunAsAdministrator
Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4624
    StartTime = [datetime]::Now.AddHours(-1)
} -MaxEvents 1 -Verbose

$milliSeconds = 3600 * 1000 # 1 hour in milliseconds
$Filter = '*[System[(EventID = 4624) and TimeCreated[timediff(@SystemTime) <= {0}]]]' -f $milliSeconds
Get-WinEvent -LogName Security -FilterXPath $Filter

# https://docs.microsoft.com/windows/win32/wes/consuming-events

Get-WinEvent -FilterHashtable @{
    LogName      = 'Application'
    ProviderName = 'Application Error'
    Data         = 'vmconnect.exe'
} -Verbose

$Filter = '*[System/Provider[@Name="application error"] and (EventData/Data="vmconnect.exe")]'
Get-WinEvent -LogName Application -FilterXPath $filter

# https://github.com/peetrike/scripts/blob/master/src/ComputerManagement/EventLog/Get-LogonReport.ps1
# https://github.com/peetrike/scripts/blob/master/src/RdpServer/Get-RdpLogonReport.ps1

#endregion

#region Using XML Filtering

Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4624
    StartTime = [datetime]::Now.AddHours(-1)
} -MaxEvents 1 -Verbose

$FilterXml = @'
<QueryList>
  <Query Id="0" Path="application">
    <Select Path="application">
      *[System/Provider[@Name='application error'] and (EventData/Data='vmconnect.exe')]
    </Select>
  </Query>
</QueryList>
'@

Get-WinEvent -FilterXml $FilterXml
#endregion
