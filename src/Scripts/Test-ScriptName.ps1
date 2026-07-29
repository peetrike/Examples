
New-Module -name Automation {
    function Get-ScriptName {
        [CmdletBinding()]
        param ()

        $namePattern = '\.ps1$'
        $StackItem = Get-PSCallStack | Where-Object Command -Match $namePattern
        $StackItem.Command -replace $namePattern
    }

    function Get-ScriptInfo {
        [CmdletBinding()]
        param ()

        Get-ScriptName
    }
    Export-ModuleMember Get-ScriptInfo
} | Import-Module

Get-ScriptInfo
