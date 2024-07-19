<#
    .DESCRIPTION
        Test Component Based Servicing reboot required events
#>

[OutputType([bool])]
[CmdletBinding()]
param (
        [datetime]
    $After
)

$Provider = 'Microsoft-Windows-Servicing'

$EventProps = @{
    ProviderName = $Provider
    Id           = 1    # Initiating changes
}
$VerboseOff = @{
    Verbose = $false
}

if (-not $After) {
    $CurrentEvent = Get-WinEvent -MaxEvents 1 -FilterHashtable $EventProps @VerboseOff
    $After = $CurrentEvent.TimeCreated
}
$EventProps.StartTime = $After
$EventProps.Id = 4      # A reboot is necessary
$restartEvent = Get-WinEvent -FilterHashtable $EventProps @VerboseOff

$EventProps.Id = 2      # Package was successfully changed to the Installed state.
$InstalledEvent = Get-WinEvent -FilterHashtable $EventProps @VerboseOff

foreach ($e in $restartEvent) {
    $PackageId = $e.Properties[0].Value
    $InstalledEvent |
        Where-Object { $_.Properties[0].Value -eq $PackageId } |
        ForEach-Object {
            Write-Verbose -Message ('Found installed event for {0}' -f $PackageId)
            continue
        }
    Write-Verbose -Message ('Restart is required for package: {0}' -f $PackageId)
    $true
    break
}
