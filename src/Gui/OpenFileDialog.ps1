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
[Enum]::GetValues([Windows.Forms.DialogResult])

if ($result -eq [Windows.Forms.DialogResult]::OK) {
    $OpenFileDialog.FileNames
}
