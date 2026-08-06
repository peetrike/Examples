[CmdletBinding()]
param ()

New-Module -name Automation {
    function Get-ScriptName {
        [CmdletBinding()]
        param ()

        $namePattern = '\.ps1$'
        $ScriptPath = Get-PSCallStack |
            Select-Object -First 1 -ExpandProperty ScriptName
        (Split-Path -Path $ScriptPath -Leaf) -replace $namePattern
    }

    function Get-ScriptInfo {
        [CmdletBinding()]
        param ()

        Get-ScriptName
    }
    Export-ModuleMember Get-ScriptInfo
} | Import-Module -Verbose:$false

Get-ScriptInfo
