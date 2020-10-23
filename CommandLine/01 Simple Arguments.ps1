<#
    .SYNOPSIS
        Shows simple command line arguments usage
    .DESCRIPTION
        This script is about showing how you can get all command line arguments in one array: $args
    .EXAMPLE
        & './01 Simple Arguments.ps1' one two three

        Will show all given 3 arguments and number of arguments (3)
    .LINK
        https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_automatic_variables
#>

"The number of command line args is: {0}" -f $args.Count

"The command line args themselves:"
$args

"`nProcess all arguments one at a time"
foreach ($argument in $args) {
    "Next argument:"
    $argument
}
