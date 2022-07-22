#Requires -Version 2.0

<#PSScriptInfo
    .VERSION 10.394.10876-preview1

    .GUID fd7bdb09-be21-45bc-b74a-e086639d1d05
    .AUTHOR Peter Wawa
#>

<#
    .SYNOPSIS
        Shows how to use version info in script metadata.
    .DESCRIPTION
        This script shows how to use version info from script metadata as
        version number returned to script caller.

        PowerShell 5 has module PowerShellGet with Test-ScriptFileInfo cmdlet.
        When PowerShellGet is not installed or when version is not supported by
        Test-ScriptFileInfo cmdlet, Regular Expression can be used to find same information.
    .INPUTS
        This script doesn't take pipeline input.
    .NOTES
        - Test-ScriptFileInfo before v1.6.0 only supports [System.Version] compatible version string.
        - Test-ScriptFileInfo v1.6.0 and newer only supports SemVer v1.0.0 compatible version string.
    .LINK
        https://docs.microsoft.com/powershell/scripting/gallery/concepts/script-prerelease-support
#>

[OutputType('System.Management.Automation.SemanticVersion')]
[OutputType([version])]
[OutputType([string])]
[CmdletBinding()]
param (
        [parameter(
            ParameterSetName = 'Version'
        )]
        [Alias('v')]
        [switch]
        # Returns script version info (as version object)
    $Version,
        [parameter(
            ParameterSetName = 'Version'
        )]
        [Alias('String')]
        [switch]
        # Returns script version info as string
    $AsString
)

# Show script version
if ($Version.IsPresent) {
    try {
        $null = Get-Command Test-ScriptFileInfo -ErrorAction Stop
        Write-Verbose -Message 'Using Test-ScriptFileInfo'
        $ScriptInfo = Test-ScriptFileInfo -Path $PSCommandPath
            # different versions of Test-ScriptFileInfo return version with different data type
        $ver = $ScriptInfo.Version.ToString()
    } catch {
        Write-Verbose -Message 'Using Select-String'
        $result = Select-String -Path $MyInvocation.MyCommand.Path -Pattern '^\s*\.VERSION (\d+(\.\d+){0,3})'
        $ver = $result.Matches[0].Groups[1].Value
    }
    if ($AsString) {
        return $ver
    } else {
        try {
            return [semver] $ver
        } catch {
            return [version] $ver.Split('-')[0]
        }
    }
}

Write-Warning -Message 'Use -Version to see script version'
