#Requires -Version 3

[CmdletBinding()]
param (
    [String[]]
    $Module
)

$HelpInfoNamespace = @{ helpInfo = 'http://schemas.microsoft.com/powershell/help/2010/05' }

$ModuleParams = @{
    ListAvailable = $true
}
if ($Module) {
    $ModuleParams.Name = $Module
}

$Modules = Get-Module @ModuleParams | Where-Object -FilterScript { $_.HelpInfoUri }

foreach ($mModule in $Modules) {
    $mDir = $mModule.ModuleBase

    if (Test-Path $mdir\*helpinfo.xml) {
        $mNodes = Get-ChildItem -Path $mdir\*helpinfo.xml -ErrorAction SilentlyContinue |
            Select-Xml -Namespace $HelpInfoNamespace -XPath '//helpInfo:UICulture'
        foreach ($mNode in $mNodes) {
            $mCulture = $mNode.Node.UICultureName
            $mVer = $mNode.Node.UICultureVersion

            [PSCustomObject]@{
                ModuleName = $mModule.Name
                Culture    = $mCulture
                Version    = $mVer
            }
        }
    }
}
