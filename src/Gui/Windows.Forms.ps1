$message = 'Should we do something?'
$title = 'A message'

#region Load Assembly if necessary
try {
    $null = [Windows.Forms.MessageBoxButtons]::OK
} catch {
    Add-Type -AssemblyName System.Windows.Forms
}
#endregion


#region MessageBox

# https://docs.microsoft.com/dotnet/api/system.windows.forms.messagebox.show
$result = [Windows.Forms.MessageBox]::Show($message)
$result = [Windows.Forms.MessageBox]::Show($message, $title)

# https://docs.microsoft.com/dotnet/api/system.windows.forms.messageboxbuttons
[Enum]::GetValues([Windows.Forms.MessageBoxButtons])
[Windows.Forms.MessageBoxButtons]'YesNoCancel'
[Windows.Forms.MessageBoxButtons]::OK

$ButtonOption = [Windows.Forms.MessageBoxButtons]::YesNoCancel
$result = [Windows.Forms.MessageBox]::Show(
    $message,
    $title,
    $ButtonOption
)

# https://docs.microsoft.com/dotnet/api/system.windows.forms.messageboxicon
[Enum]::GetValues([Windows.Forms.MessageBoxIcon])
[Windows.Forms.MessageBoxIcon]'hand'
$IconOption = [Windows.Forms.MessageBoxIcon]::Warning
$result = [Windows.Forms.MessageBox]::Show(
    $message,
    $title,
    $ButtonOption,
    $IconOption
)

# https://docs.microsoft.com/dotnet/api/system.windows.forms.messageboxdefaultbutton
[Enum]::GetValues([Windows.Forms.MessageBoxDefaultButton])
[Windows.Forms.MessageBoxDefaultButton]'button3'
$DefaultButton = [Windows.Forms.MessageBoxDefaultButton]::Button3
$result = [Windows.Forms.MessageBox]::Show(
    $message,
    $title,
    $ButtonOption,
    $IconOption,
    $DefaultButton
)

#endregion

#region Notification balloon (toast message in Windows 10)

try {
    $null = [Drawing.Icon]
} catch {
    Add-Type -AssemblyName System.Drawing
}

# https://docs.microsoft.com/dotnet/api/System.Windows.Forms.NotifyIcon
$NotifyIcon = New-Object System.Windows.Forms.NotifyIcon

# https://docs.microsoft.com/dotnet/api/system.drawing.icon
# $NotifyIcon.Icon = [Drawing.Icon]::new('C:\Program Files\PowerShell\7\assets\Powershell_black.ico')
# https://docs.microsoft.com/dotnet/api/system.drawing.systemicons
$NotifyIcon.Icon = [Drawing.SystemIcons]::Question

$NotifyIcon.Text = 'A notification from script'
    # This makes system tray icon visible
$NotifyIcon.Visible = $True

# https://docs.microsoft.com/dotnet/api/system.windows.forms.tooltipicon
# $NotifyIcon.BalloonTipIcon = [Windows.Forms.ToolTipIcon]::Info
# $NotifyIcon.BalloonTipIcon = 'Info'

$NotifyIcon.BalloonTipText = $message
$NotifyIcon.BalloonTipTitle = $title

# when giving too small time for balloon tip, Windows applies system default timing
$NotifyIcon.ShowBalloonTip(0)

Start-Sleep -Seconds 10

    # remove the icon from system tray
$NotifyIcon.Visible = $false
#endregion
