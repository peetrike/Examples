#Requires -Version 5
#Requires -PSEdition Desktop

$message = 'Should we do something?'
$title = 'A message'

$StartAppList = Get-StartApps -Name PowerShell

$StartApp = if ($PSVersionTable.PSEdition -eq 'Desktop') {
    $StartAppList | Where-Object Name -Like 'Windows PowerShell'
} elseif ($PSVersionTable.PSVersion.Major -gt 5) {
    $StartAppList | Where-Object Name -Like PowerShell | Select-Object -First 1
}

$AppId = $StartApp.AppId

$null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
$null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]

$XmlString = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>$title</text>
            <text>$message</text>
        </binding>
    </visual>
    <audio src="ms-winsoundevent:Notification.Default" />
</toast>
"@

$ToastXml = [Windows.Data.Xml.Dom.XmlDocument]::new()
$ToastXml.LoadXml($XmlString)
$Toast = [Windows.UI.Notifications.ToastNotification]::new($ToastXml)

[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId).Show($Toast)
