function Get-LogonSession {
    [CmdletBinding()]
    param (
            [switch]
        $IncludeProcess
    )

    enum SessionType {
        System
        Interactive = 2
        Network
        Batch
        Service
        Proxy
        Unlock
        NetworkClearText
        NewCredentials
        RemoteInteractive
        CachedInteractive
        CachedRemoteInteractive
        CachedUnlock
    }
    $PropertySet = @(
        'AuthenticationPackage'
        'StartTime'
        'LogonId'
    )

    foreach ($Session in Get-CimInstance -ClassName Win32_LogonSession) {
        $SessionProps = @{
            LogonType = [SessionType] $Session.LogonType
        }
        foreach ($property in $PropertySet) {
            $SessionProps.$property = $Session.$property
        }
        $User = Get-CimAssociatedInstance -InputObject $Session -Association Win32_LoggedonUser

        $SessionProps.User = $User
        if ($IncludeProcess) {
            $SessionProps.Process =
                Get-CimAssociatedInstance -InputObject $Session -Association Win32_SessionProcess
        }
        [PSCustomObject] $SessionProps
    }
}

Get-LogonSession
