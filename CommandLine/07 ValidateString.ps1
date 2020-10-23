<#
    .SYNOPSIS
        Shows arguments with string validation attribute.
    .DESCRIPTION
        This script is using named arguments with string validation attributes.
        ValidatePattern will use .NET regular expression syntax to validate the value.
    .EXAMPLE
        & './07 ValidateString.ps1' -Name Me

        This example will work as regular expression matches the value.
    .EXAMPLE
        & './07 ValidateString.ps1' -Name You

        This example will fail because regular expression doesn't match.
    .EXAMPLE
        & './07 ValidateString.ps1' -Name Me -Greeting Hi

        This example will fail as parameter Greeting is too short.
    .LINK
        https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_regular_expressions
    .LINK
        https://docs.microsoft.com/dotnet/standard/base-types/regular-expression-language-quick-reference
    .LINK
        https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
#>

param (
        [ValidatePattern('M.+')]
        [string]
    $Name,
        [ValidateLength(3,5)]
        [string]
    $Greeting = 'Hello'
)

if ($Name) {
    '{0} {1}' -f $Greeting, $Name
}
