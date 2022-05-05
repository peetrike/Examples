[CmdletBinding()]
param (
        [string]
    $QueryName = 'rdm.et.ee',
        [int]
    $Hours = 1
)
Get-WinEvent -FilterHashtable @{
    LogName   = 'Microsoft-Windows-DNS-Client/Operational'
    Id        = 3008
    StartTime = [datetime]::Now.AddHours(-$Hours)
    Data      = $QueryName
} | ForEach-Object {
    $xmlevent = [xml]$_.ToXml()
    $ProcessId = $xmlevent.event.System.Execution.ProcessId
    $Process = Get-Process -id $ProcessId
    $ParentProcess = Get-Process -Id (
        Get-CimInstance Win32_Process -Filter "ProcessId = $ProcessId"
    ).ParentProcessId
    [pscustomObject] @{
        TimeCreated = $_.TimeCreated
        QueryName   = $xmlevent.SelectNodes('//*[@Name = "QueryName"]').InnerText
        ProcessId   = $ProcessId
        ProcessName = $Process.Name
        ProcessPath = $Process.Path
        Parent      = $ParentProcess.Name
    }
}
