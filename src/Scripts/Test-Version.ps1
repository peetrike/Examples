#Requires -Version 2.0

<#PSScriptInfo
    .VERSION 32.17.900.6500
    .GUID f5630c89-b36f-4e1a-89d2-f74caf9c318d

    .AUTHOR Peter Wawa
#>

<#
    .SYNOPSIS
        Shows script version from PSScriptInfo section
    .DESCRIPTION
        This script shows how to get script version form PSScriptInfo comment section
    .EXAMPLE
        Test-Version.ps1 -Version
        Shows script version
    .NOTES
        It also uses minimal amount of information in PSScriptInfo section
#>

[CmdletBinding()]
param (
        [parameter(
            ParameterSetName = 'Version'
        )]
        [switch]
        # Shows script version
    $Version,
        [parameter(
            ParameterSetName = 'Version'
        )]
        [switch]
        # Returns version as string
    $AsString
)

if ($Version) {
    try {
        $VersionInfo = (Test-ScriptFileInfo -Path $PSCommandPath -ErrorAction Stop).Version
    } catch {
        Write-Verbose -Message 'Test-ScriptFileInfo failed, reverting to regular expression search'
        $result = Select-String -Path $MyInvocation.MyCommand.Path -Pattern '^\s*\.VERSION (\d+(\.\d+){0,3})$'
        $VersionInfo = ($result.Matches | Select-Object -ExpandProperty Groups)[1].Value
    }

    if ($AsString) {
        $VersionInfo
    } else {
        [version] $VersionInfo
    }
} else {
    'This script does nothing'
}
