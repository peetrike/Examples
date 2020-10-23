<#
    .SYNOPSIS
        Shows arguments with count validation attribute
    .DESCRIPTION
        This script is using named arguments with ValidateCount attribute.
        This validation assumes collection type and allows only specified number of elements.
    .EXAMPLE
        & './06 ValidateCount.ps1' -Value one,two,three

        This example will work as there are enough values in collection.
    .EXAMPLE
        & './06 ValidateCount.ps1' -Value 1,2,3,4,5,6

        This example will fail because there are too many values in collection.
    .EXAMPLE
        & './06 ValidateCount.ps1' -Value 10,20

        This example will also fail because there are too few values in collection.
    .EXAMPLE
        & './06 ValidateCount.ps1' -Value (Get-ChildItem 06*)

        This example will also fail because one element is not collection type.
    .LINK
        https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
#>

param (
        [ValidateCount(3,5)]
    $Value
)

if ($Value) {
    'The type of value: {0}' -f $Value.Gettype()
    'Number of values: {0}' -f$Value.Count
}
