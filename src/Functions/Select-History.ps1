function Select-History {
    Get-History |
        Out-GridView -Title 'Select your history lines to rerun' -PassThru |
        ForEach-Object { Invoke-History $_ }
}
