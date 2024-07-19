<#
    .LINK
        https://adamtheautomator.com/pending-reboot-registry/
    .LINK
        https://devblogs.microsoft.com/scripting/determine-pending-reboot-statuspowershell-style-part-1
    .LINK
        https://learn.microsoft.com/previous-versions/windows/it-pro/windows-2000-server/cc960241(v=technet.10)
    .LINK
        https://learn.microsoft.com/previous-versions/windows/it-pro/windows-server-2008-r2-and-2008/cc756243(v=ws.10)
    .LINK
        https://support.microsoft.com/topic/7365340e-0aa9-231a-4297-34bc2097bbe9
    .LINK
        https://learn.microsoft.com/en-us/mem/configmgr/develop/reference/core/clients/sdk/determineifrebootpending-method-in-class-ccm_clientutilities
    .LINK
        # https://learn.microsoft.com/windows/win32/api/wuapi/nf-wuapi-isysteminformation-get_rebootrequired
#>

function Test-PendingReboot {
    [OutputType([bool], [psobject])]
    [CmdletBinding()]
    param (
            [switch]
        $IncludeConfigMgrClient,
            [switch]
        $IncludePendingFileRename,
            [switch]
        $Detailed
    )

    function Test-RegValue {
        [OutputType([bool])]
        [CmdletBinding()]
        param (
                [string]
            $RegPath,
                [string[]]
            $ValueName
        )

        $regValue = Get-ItemProperty -Path $regPath
        foreach ($value in $ValueName) {
            if ($regvalue -contains $value) {
                Write-Verbose -Message ('{0} found in {1}' -f $value, $regPath)
                return $true
            }
        }
        $false
    }

        # Query the Component Based Servicing Reg Key
    $RegTestParams = @{
        RegPath   = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing'
        ValueName = 'RebootPending'
    }
    $PendingComponentBasedServicing = Test-RegValue @RegTestParams

        # Query Windows Update Agent
    $PendingWindowsUpdate = try {
        $SystemInfo = New-Object -ComObject Microsoft.Update.SystemInfo
        $SystemInfo.RebootRequired
    } catch {
        Write-Verbose -Message 'WUAU API call failed, trying registry key...'
        $RegTestParams = @{
            RegPath   = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update'
            ValueName = 'RebootRequired'
        }
        Test-RegValue @RegTestParams
    }

        # Query JoinDomain key from the registry.
    $RegTestParams = @{
        RegPath   = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon'
        ValueName = 'JoinDomain', 'AvoidSpnSet'
    }
    $pendingJoinDomain = Test-RegValue @RegTestParams

        # Query ComputerName and ActiveComputerName from the registry
    $valueName = 'ComputerName'
    $regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName'
    $registryComputerName = (Get-ItemProperty -Path $regPath -Name $valueName).$valueName

    $regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName'
    $registryActiveComputerName = (Get-ItemProperty -Path $RegPath -Name $ValueName).$valueName

    $PendingComputerRename = $registryActiveComputerName -ne $registryComputerName -or $pendingJoinDomain

    if ($IncludePendingFileRename) {
            # Query PendingFileRenameOperations from the registry
        $regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
        $regValue = Get-ItemProperty -Path $regPath
        $PendingFileRename = [bool] $regValue.PendingFileRenameOperations
    }

    if ($IncludeConfigMgrClient) {
            # Query ClientSDK for pending reboot status
        $CimMethodParams = @{
            Namespace  = 'ROOT\ccm\ClientSDK'
            ClassName  = 'CCM_ClientUtilities'
            MethodName = 'DetermineIfRebootPending'
            #ErrorAction = [Management.Automation.ActionPreference]::Stop
        }
        $CimResult = Invoke-CimMethod @CimMethodParams
        if ($CimResult.ReturnValue -eq 0) {
            $PendingConfigMgr = $CimResult.IsHardRebootPending -or $CimResult.RebootPending
        } else {
            Write-Warning -Message ('ConfigMgr WMI call ended with result code: {0}' -f $CimResult.ReturnValue)
        }
    }

    if ($Detailed) {
        [PSCustomObject] @{
            ComponentBasedServicing  = $PendingComponentBasedServicing
            ComputerRenameDomainJoin = $PendingComputerRename
            FileRenameOperations     = $PendingFileRename
            ConfigMgr                = $PendingConfigMgr
            WindowsUpdate            = $PendingWindowsUpdate
        }
    }else {
        $PendingComponentBasedServicing -or
            $PendingComputerRename -or
            $PendingFileRename -or
            $PendingConfigMgr -or
            $PendingWindowsUpdate
    }
}
