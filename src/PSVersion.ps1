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
    <# $startInfo = [Diagnostics.ProcessStartInfo]'powershell.exe'
    $startInfo.Arguments = '-NoProfile $PSVersionTable.PSVersion.ToString()'
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.UseShellExecute = $false     # this enables redirection of input, output, and error streams.

    $process = [Diagnostics.Process]::Start($startInfo)
    $Version = [version] $process.StandardOutput.ReadToEnd() #>

    $Version = powershell.exe -NoProfile -c { $PSVersionTable.PSVersion }
    <# if (-not $process.HasExited) {
        $process.WaitForExit()
    } #>
}

if ($Major.IsPresent) {
    $Version.Major
} else {
    $Version.ToString()
}
