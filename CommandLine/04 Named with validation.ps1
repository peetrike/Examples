<#
    .SYNOPSIS
        Shows arguments with validation attributes
    .DESCRIPTION
        This script is using named arguments with validation attributes.
        Specific validation attributes assume specific data types.
    .EXAMPLE
        & './04 Named with validation.ps1' -Command Add -Value 7

        Will assign 'Add' as command and 7 as value to process.  You can use tab completion to cycle through
        validate set values.
    .EXAMPLE
        & './04 Named with validation.ps1' -Command Push -Value 6

        This example will fail because parameter $Command has value which is not in validation set.
    .EXAMPLE
        & './04 Named with validation.ps1' -Command Remove -Value 13

        This example will fail because parameter $Value has value out of allowed range.
    .EXAMPLE
        & './04 Named with validation.ps1' -Command Change -Value thirteen

        This example will fail because parameter $Value has value that cannot be converted to [int].
    .EXAMPLE
        & './04 Named with validation.ps1' -Command add -Value2 7

        This example will fail because parameter $Value2 has value that is not negative.
    .LINK
        https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
#>

param (
        [ValidateSet(
            'Add',
            'Remove',
            'Change'
        )]
    $Command,
        [ValidateRange(2,10)]
    $Value,
        [ValidateRange('Negative')]
        [int]
    $Value2
)

switch ($Command) {
    'Add' {
        "adding value: {0}" -f $Value
    }
    default {
        "I don't know what to do with $Value"
    }
}
