#Requires -Modules ConfigDefender

$Prefs = Get-MpPreference
foreach ($Property in (Get-Member -InputObject $Prefs -Name Exclusion*).Name) {
    $Prefs.$Property | ForEach-Object {
        @{ $Property = $_ }
    }
}
