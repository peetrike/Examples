#Requires -Version 2.0

<#PSScriptInfo
    .VERSION 1.0.0
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
Param(
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

if ($Version.IsPresent) {
    try {
        $VersionInfo = (Test-ScriptFileInfo -Path $PSCommandPath -ErrorAction Stop).Version
    } catch {
        Write-Verbose -Message 'Test-ScriptFileInfo failed, reverting to regular expression search'
        $result = Select-String -Path $MyInvocation.MyCommand.Path -Pattern '\.Version (.*)$'
        $VersionInfo = ($result[0].Matches | Select-Object -ExpandProperty Groups)[1].Value
    }

    if ($AsString.IsPresent) {
        $VersionInfo
    } else {
        [version] $VersionInfo
    }
} else {
    'This script does nothing'
}
