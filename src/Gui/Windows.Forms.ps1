$message = 'Should we do something?'
$title = 'A message'

#region Load Assembly if necessary
try {
    $null = [Windows.Forms.MessageBoxButtons]::OK
} catch {
    Add-Type -AssemblyName System.Windows.Forms
}
#endregion

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
