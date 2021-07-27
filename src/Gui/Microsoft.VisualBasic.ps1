$message = 'Should we do something?'
$title = 'A message'

#region Microsoft.VisualBasic
try {
    $null = [Microsoft.VisualBasic.MsgBoxStyle]::YesNo
} catch {
    Add-Type -AssemblyName Microsoft.VisualBasic
}

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
