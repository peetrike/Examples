function Connect-OfflineFiles {
    <#
        .SYNOPSIS
            Connects to the Offline Files network location.
        .DESCRIPTION
            This function brings Offline Files location to online state.
        .EXAMPLE
            Connect-OfflineFiles -path \\server\share\path

            This command brings the specified Offline Files location online.
    #>
    [CmdletBinding()]
    param (
            [ValidateScript({
                Test-Path $_ -PathType Container
            })]
            [string]
        $Path
    )

    $invokeCimMethodSplat = @{
        ClassName  = 'Win32_OfflineFilesCache'
        MethodName = 'TransitionOnline'
        Arguments  = @{
            Path  = $Path
            Flags = [UInt32] 1
        }
    }

    Invoke-CimMethod @invokeCimMethodSplat
}
