function Get-FailedUpdate {
    <#
        .LINK
            https://learn.microsoft.com/windows/win32/wua_sdk/portal-client
    #>
    [CmdletBinding()]
    param (
            [int]
        $Days,
            [int]
        $Latest = [int]::MaxValue,
            [switch]
        $UpdateOnly,
            [switch]
        $ExcludeDefender

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

    try {
        $Searcher.QueryHistory(0, $HistoryCount) |
        Where-Object {
            $_.Date -gt $AfterDate -and
            $_.ResultCode -gt 2 -and      # Not successful
            $_.Operation -eq 1 -and
            (-not $ExcludeDefender -or ($ExcludeDefender -and $_.Title -notmatch 'Defender')) -and
            (-not $UpdateOnly -or ($UpdateOnly -and $_.Title -match 'KB\d{6,7}'))
        } |
        Select-Object -First $Latest |
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
    } catch {
        throw
    }
}
