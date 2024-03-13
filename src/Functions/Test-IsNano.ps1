function Test-IsNano {
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Server\ServerLevels\'
    $IsNano = Get-ItemProperty -Path $regPath -Name NanoServer -ErrorAction SilentlyContinue
    [bool] $IsNano
}
