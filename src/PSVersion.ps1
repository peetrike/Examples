[CmdletBinding()]
param (
        [switch]
    $Major
)

$Version = $PSVersionTable.PSVersion

if (
    $Version.Major -eq 2 -and
    (Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\PowerShell\3' -ErrorAction SilentlyContinue)
) {
    $Version = powershell.exe -NoProfile -c { $PSVersionTable.PSVersion }
}

if ($Major.IsPresent) {
    $Version.Major
} else {
    $Version.ToString()
}
