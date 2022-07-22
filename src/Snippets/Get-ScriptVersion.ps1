#Requires -Version 2.0

<#PSScriptInfo
    .VERSION 10.394.10876.8

    .GUID fd7bdb09-be21-45bc-b74a-e086639d1d05
    .AUTHOR Peter Wawa
#>

<#
    .DESCRIPTION
        Shows how to use version info in script metadata
#>

[CmdletBinding()]
param (
        [parameter(
            ParameterSetName = 'Version'
        )]
        [switch]
    $Version,
        [parameter(
            ParameterSetName = 'Version'
        )]
        [Alias('String')]
        [switch]
    $AsString
)

# Show script version
if ($Version.IsPresent) {
    try {
        $null = Get-Command Test-ScriptFileInfo -ErrorAction Stop
            # different versions of Test-ScriptFileInfo return version as different type
        $ver = (Test-ScriptFileInfo -Path $PSCommandPath).Version.ToString()
    } catch {
        $result = Select-String -Path $MyInvocation.MyCommand.Path -Pattern '^\s*\.VERSION (\d+(\.\d+){0,3})$'
        $ver = $result.Matches[0].Groups[1].Value
    }
    if ($AsString) {
        return $ver
    } else {
        return [version] $ver
    }
}

Write-Warning -Message 'Use -Version to see script version'
