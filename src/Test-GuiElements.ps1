$message = 'Should we do something?'
$title = 'A message'

#region Microsoft.VisualBasic
Add-Type -AssemblyName Microsoft.VisualBasic

#region VB input box

# https://docs.microsoft.com/dotnet/api/microsoft.visualbasic.interaction.inputbox
$computer = [Microsoft.VisualBasic.Interaction]::InputBox(
    'Enter a computer name',
    $title,
    $env:COMPUTERNAME
)
$computer

#endregion

#region VB message box

# https://docs.microsoft.com/dotnet/api/microsoft.visualbasic.interaction.msgbox
$result = [Microsoft.VisualBasic.Interaction]::MsgBox($message)
$result

# https://docs.microsoft.com/dotnet/api/microsoft.visualbasic.msgboxstyle
[Enum]::GetValues([Microsoft.VisualBasic.MsgBoxStyle])

[Microsoft.VisualBasic.MsgBoxStyle]'OkCancel'
[Microsoft.VisualBasic.MsgBoxStyle]::YesNo
[Microsoft.VisualBasic.MsgBoxStyle]::Question + 4 # [Microsoft.VisualBasic.MsgBoxStyle]::YesNo
[Microsoft.VisualBasic.MsgBoxStyle]'YesNo,Question'

$ButtonOption = [Microsoft.VisualBasic.MsgBoxStyle]'YesNo, Question'
$result = [Microsoft.VisualBasic.Interaction]::MsgBox(
    $message,
    $ButtonOption,
    $title
)
# https://docs.microsoft.com/dotnet/api/microsoft.visualbasic.msgboxresult
$result | Get-Member

#endregion

#endregion

#region Windows.Forms message box
Add-Type -AssemblyName System.Windows.Forms

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

#region WSH shell message box
$WshShell = New-Object -ComObject WScript.Shell

# https://docs.microsoft.com/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/x83z1d9f(v=vs.84)
$null = $WshShell.Popup($message)

$ButtonOption = 4+32 #[microsoft.visualbasic.msgboxstyle]'YesNo,Question'
$result = $WshShell.Popup(
    $message,
    5,              # seconds to wait
    $title,
    $ButtonOption
)

$WshShell | Get-Member

#endregion

#region Powershell Prompt for Choices
# https://docs.microsoft.com/dotnet/api/System.Management.Automation.Host.ChoiceDescription
$yes = New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes', 'Yes, do it'
$no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'No, leave it as it is.'
$cancel = [Management.Automation.Host.ChoiceDescription]'&Cancel'

$options = ($yes, $no, $cancel)

# https://docs.microsoft.com/dotnet/api/system.management.automation.host.pshostuserinterface.promptforchoice
$result = $host.ui.PromptForChoice(
    $title,
    $message,
    $options,
    2           # default choice
)

switch ($result) {
    0 { 'You selected Yes.' }
    1 { 'You selected No.' }
    2 { 'You selected Cancel.' }
}

#endregion

#region Powershell commands

$result = Read-Host -Prompt $message

#Requires -Version 3
$CredentialProps = @{
    UserName = 'Give me some information'
}

switch ($PSVersionTable.PSVersion.Major) {
    { $_ -ge 6 } {
        $CredentialProps.Title = $title
    }
    Default {
        $CredentialProps.Message = $message
    }
}

$result = Get-Credential @CredentialProps
$result.UserName
$result.GetNetworkCredential().Password
#endregion

#region Open File Dialog

# https://docs.microsoft.com/dotnet/api/System.Windows.Forms.OpenFileDialog

try {
    $null = [Windows.Forms.OpenFileDialog]
} catch {
    Add-Type -AssemblyName System.Windows.Forms
}
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.InitialDirectory = 'c:\'
$OpenFileDialog.Filter = 'CSV (*.csv)| *.csv|All files (*.*)|*.*'
$OpenFileDialog.Multiselect = $true
$result = $OpenFileDialog.ShowDialog()

# https://docs.microsoft.com/dotnet/api/system.windows.forms.dialogresult
[Enum]::GetValues([System.Windows.Forms.DialogResult])

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $OpenFileDialog.FileNames
}
#endregion
