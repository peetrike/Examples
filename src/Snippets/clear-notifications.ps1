$regpath = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Notifications'
$hklm = [Microsoft.Win32.Registry]::LocalMachine
$key = $hklm.OpenSubKey($regpath, $true)

$key.GetValueNames() -match '^\d' | foreach { $key.DeleteValue($_) }

$key.GetValueNames() | Measure-Object
