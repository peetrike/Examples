function Get-FailedUpdate {
    <#
        .LINK
            https://learn.microsoft.com/windows/win32/wua_sdk/portal-client
    #>
    [CmdletBinding()]
    param (
        $Days
    )

    try {
        $null = [WUA]
    } catch {
        Add-Type -TypeDefinition @'
            namespace WUA {
                public enum ServerSelection {
                    Default,
                    ManagedServer,
                    WindowsUpdate,
                    Other
                }
                public enum ResultCode {
                    NotStarted,
                    InProgress,
                    Succeeded,
                    SucceededWithErrors,
                    Failed,
                    Aborted
                }
            }
'@
    }


    function Get-UpdateService {
        param (
                #[AllowNull()]
                [string]
            $ServiceId,
            $ServiceManager
        )
        if ($ServiceId) {
            $ServiceManager.Services |
            Where-Object { $_.ServiceId -eq $ServiceId } |
            ForEach-Object {
                [PSCustomObject]@{
                    PSTypeName   = 'WUA.UpdateService'
                    Name         = $_.Name
                    ServiceId    = $_.ServiceId
                    IsManaged    = $_.IsManaged
                    IsRegistered = $_.IsRegisteredWithAU
                    IsDefault    = $_.IsDefaultAUService
                }
            }
        } else {
            $null
        }
    }

    $AfterDate = if ($Days) {
        [datetime]::Now.AddDays(-$Days)
    } else { [datetime] 0 }

    $ServiceManager = New-Object -ComObject Microsoft.Update.ServiceManager
    $Session = New-Object -ComObject Microsoft.Update.Session
    $Searcher = $Session.CreateUpdateSearcher()

    $HistoryCount = $Searcher.GetTotalHistoryCount()

    $Searcher.QueryHistory(0, $HistoryCount) |
        Where-Object {
            $_.Date -gt $AfterDate -and
            $_.ResultCode -gt 2 -and      # Not successful
            $_.Operation -eq 1
        } |
        ForEach-Object {
            $Service = Get-UpdateService -ServiceId $_.ServiceId -ServiceManager $ServiceManager
            [PSCustomObject]@{
                PSTypeName      = 'WUA.Update'
                Date            = $_.Date
                Title           = $_.Title
                ServerSelection = [WUA.ServerSelection] $_.ServerSelection
                ServiceId       = $Service
                ResultCode      = [WUA.ResultCode] $_.ResultCode
                SupportUrl      = $_.SupportUrl
                HResult         = $_.HResult
                UnmappedResultCode = $_.UnmappedResultCode
            }
        }
}
