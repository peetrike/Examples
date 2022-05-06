[CmdletBinding()]
param (
        [string]
    $QueryName = 'www.ee',
        [int]
    $Hours = 1
)
Get-WinEvent -FilterHashtable @{
    LogName   = 'Microsoft-Windows-DNS-Client/Operational'
    Id        = 3008    # DNS query is completed for the name
    StartTime = [datetime]::Now.AddHours(-$Hours)
    Data      = $QueryName
} | ForEach-Object {
    $xmlEvent = [xml]$_.ToXml()
    $ProcessId = $_.ProcessId
    if ($Process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue) {
        $parentProccessId = (
            Get-CimInstance Win32_Process -Filter "ProcessId = $ProcessId" -ErrorAction Ignore
        ).ParentProcessId
        if ($parentProccessId) {
            $ParentProcess = Get-Process -Id $parentProccessId
        } else {
            $ParentProcess = $null
        }
    } else {
        $Process = $ParentProcess = $null
    }

    [pscustomObject] @{
        TimeCreated = $_.TimeCreated
        QueryName   = $xmlEvent.SelectNodes('//*[@Name = "QueryName"]').InnerText
        ProcessId   = $ProcessId
        ProcessName = $Process.Name
        ProcessPath = $Process.Path
        Parent      = $ParentProcess.Name
    }
}
