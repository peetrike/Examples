
    # https://docs.microsoft.com/en-us/windows/desktop/api/wuapi/nn-wuapi-iupdatesession
$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()

    # https://docs.microsoft.com/en-us/windows/desktop/api/wuapicommon/ne-wuapicommon-tagserverselection
$Searcher.ServerSelection
$Searcher.ServiceID


    # https://docs.microsoft.com/en-us/windows/desktop/api/wuapi/nf-wuapi-iupdatesearcher-search
$searchResult = $Searcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")

$KbArticleId = @{
    Name       = 'KBArticle'
    Expression = { $_.KBArticleIds.item(0) }
}
$searchResult.Updates | Select-Object -Property MsrcSeverity, RebootRequired, $KbArticleId, Title


$HistoryCount = $Searcher.GetTotalHistoryCount()

    # https://docs.microsoft.com/en-us/windows/desktop/api/Wuapi/nn-wuapi-iupdatehistoryentry
$LastUpdate = $Searcher.QueryHistory(0, $HistoryCount) |
    Where-Object { ($_.Title -notmatch 'Defender') -and
        ($_.ResultCode -eq 2) -and
        ($_.Operation -eq 1)
    } |
    Select-Object -First 1 -Property Date, Title, ServerSelection, ServiceId #, Operation, ResultCode
        # https://docs.microsoft.com/en-us/windows/desktop/api/wuapicommon/ne-wuapicommon-tagserverselection

    <#     # https://docs.microsoft.com/en-us/windows/desktop/api/wuapi/ne-wuapi-tagoperationresultcode
    $ResultCode = switch ($LastUpdate.ResultCode) {
        0 {'Not Started'}
        1 {'In Progress'}
        2 {'Succeeded'}
        3 {'Succeeded With Errors'}
        4 {'Failed'}
        5 {'Aborted'}
    }
        # https://docs.microsoft.com/en-us/windows/desktop/api/wuapi/ne-wuapi-tagupdateoperation
    $UpdateOperation = switch ($LastUpdate.Operation) {
        1 {'Install'}
        2 {'UnInstall'}
    } #>

        # https://docs.microsoft.com/en-us/windows/desktop/api/wuapi/nn-wuapi-iautomaticupdates
$AutoUpdate = New-Object -ComObject Microsoft.Update.AutoUpdate

$AutoUpdate.Settings
$AutoUpdate.Results
$AutoUpdate.ServiceEnabled


    # https://docs.microsoft.com/windows/desktop/api/Wuapi/nn-wuapi-iupdateservicemanager
    # https://docs.microsoft.com/windows/win32/api/wuapi/nn-wuapi-iupdateservicemanager2
$ServiceManager = New-Object -ComObject Microsoft.Update.ServiceManager

$ServiceManager.Services
$ServiceManager.Services | Where-Object {$_.IsDefaultAUService}
$ServiceManager.Services | Where-Object {$_.IsManaged}
$ServiceManager.Services | Where-Object {$_.IsRegisteredWithAU}

$ServiceManager.Services | Where-Object {$_.ServiceId -eq $LastUpdate.ServiceId}

$ServiceId = '7971f918-a847-4430-9279-4a52d1efe18d'     # Microsoft Update
$ServiceManager.QueryServiceRegistration($ServiceId).Service.IsRegisteredWithAU

    # https://docs.microsoft.com/en-us/windows/desktop/api/Wuapi/nn-wuapi-iwindowsupdateagentinfo
$AgentInfo = New-Object -ComObject Microsoft.Update.AgentInfo
$AgentInfo.GetInfo('ProductVersionString')


    # https://docs.microsoft.com/en-us/windows/desktop/api/Wuapi/nn-wuapi-isysteminformation
$SystemInfo = New-Object -ComObject Microsoft.Update.SystemInfo
$SystemInfo.RebootRequired



$AUPolicy = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name UseWUServer, NoAutoUpdate, IncludeRecommendedUpdates, AUOptions, AutoInstallMinorUpdates -ErrorAction SilentlyContinue |
    Select-Object * -ExcludeProperty PS*
$WindowsUpdatePolicy = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name WUServer, WUStatusServer -ErrorAction SilentlyContinue |
    Select-Object * -ExcludeProperty PS*
$WindowsUpdate = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' -Name AUOptions, IncludeRecommendedUpdates -ErrorAction SilentlyContinue |
    Select-Object * -ExcludeProperty PS*


$GetAUOption = {
    param($AUOption)

    Switch ($AUOption) {
        0 { 'NotConfigured' }
        1 { 'Disabled' }
        2 { 'NotifyBeforeDownload' }
        3 { 'NotifyBeforeInstallation' }
        4 { 'ScheduledInstallation' }
        5 { 'AllowLocalAdminChoose' }
    }
}
