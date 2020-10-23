<#
    .SYNOPSIS
        Shows arguments with empty value validation attributes.
    .DESCRIPTION
        This script is using named arguments with various attributes that check for empty value.

        These validations are mainly used with mandatory parameters.

        Please be aware that $null and empty string '' are treated as different values.
    .EXAMPLE
        & './09 ValidateEmpty.ps1' -One $null -Two 3 -Three here -Four '' -Five @()

        This example will work as parameter One has specifically allowed to take $null value.  Without that the
        attribute will ask for value interactively every time the value is omitted.
    .EXAMPLE
        & './09 ValidateEmpty.ps1' -One here -Two $null -Three here -Four '' -Five @()

        This example will fail as parameter Two has $null assigned to it.
    .EXAMPLE
        & './09 ValidateEmpty.ps1' -One $null -Two 3 -Three '' -Four '' -Five @()

        This example will fail as parameter Three is assigned empty string.
    .EXAMPLE
        & './09 ValidateEmpty.ps1' -One $null -Two 3 -Three @() -Four '' -Five @()

        This example will fail as parameter Three is assigned empty collection.
    .EXAMPLE
        & './09 ValidateEmpty.ps1' -One $null -Two 3 -Three something

        This example will ask parameter Four value, as it is mandatory.
    .EXAMPLE
        & './09 ValidateEmpty.ps1' -One $null -Two 3 -Three something -Four ''

        This example will ask parameter Five value, as it is mandatory.
    .LINK
        https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
#>

param (
        [parameter(
            Mandatory
        )]
        [AllowNull()]
        [System.IO.FileInfo]
    $One,
        [parameter(Mandatory)]
        [ValidateNotNull()]
    $Two,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]]
    $Three,
        [parameter(Mandatory)]
        [AllowEmptyString()]
        [string]
    $Four,
        [parameter(Mandatory)]
        [AllowEmptyCollection()]
        [Object[]]
    $Five
)
