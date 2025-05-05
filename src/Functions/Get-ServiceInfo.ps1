function Get-ServiceInfo {
    [CmdletBinding()]
    param (
            [Parameter(Mandatory = $true)]
            [string]
        $ServiceName
    )

    $ProcessIdName = 'ProcessId'
    $RegPathPattern = 'HKLM:\SYSTEM\CurrentControlSet\Services\{0}'

        # Get the service information
    foreach ($service in Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
            # get additional information from registry
        $regPath = $RegPathPattern -f $service.Name
        $RegInfo = Get-ItemProperty -LiteralPath $regPath -ErrorAction SilentlyContinue

        if ($service.Status -eq 'Running') {
            $Query = 'SELECT {1} FROM Win32_Service WHERE Name = "{0}"' -f $service.Name, $ProcessIdName
                # Select-Object -ExpandProperty is for PS 2 compatibility
            $ProcessId = ([wmisearcher] $Query).Get() | Select-Object -ExpandProperty $ProcessIdName
        }

        $PropertyList = @(
            '*'
            @{
                Name       = $ProcessIdName
                Expression = { $ProcessId }
            }
            if (-not $service.BinaryPath) {
                @{
                    Name       = 'BinaryPath'
                    Expression = { $RegInfo.ImagePath }
                }
            }
            if (-not $service.UserName) {
                @{
                    Name       = 'UserName'
                    Expression = { $RegInfo.ObjectName }
                }
            }
            if (-not $service.DelayedAutoStart) {
                @{
                    Name       = 'DelayedAutoStart'
                    Expression = { [bool] $RegInfo.DelayedAutoStart }
                }
            }
        )

        $service | Select-Object -Property $PropertyList
    }
}
