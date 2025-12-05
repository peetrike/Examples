function Connect-OfflineFiles {
    <#
        .SYNOPSIS
            Connects to the Offline Files network location.
        .DESCRIPTION
            This function brings Offline Files location to online state.
        .EXAMPLE
            Connect-OfflineFiles -path \\server\share\path

            This command brings the specified Offline Files location online.
        .LINK
            https://learn.microsoft.com/previous-versions/windows/desktop/offlinefiles/win32-offlinefilescache-transitiononline
    #>
    [CmdletBinding()]
    param (
            [ValidateScript({
                Test-Path $_ -PathType Container
            })]
            [string]
        $Path
    )

    $OfflineFilesTransitionFlagInteractive = [UInt32] 1
    $invokeCimMethodSplat = @{
        ClassName  = 'Win32_OfflineFilesCache'
        MethodName = 'TransitionOnline'
        Arguments  = @{
            Path  = $Path
            Flags = $OfflineFilesTransitionFlagInteractive
        }
    }

    Invoke-CimMethod @invokeCimMethodSplat
}
