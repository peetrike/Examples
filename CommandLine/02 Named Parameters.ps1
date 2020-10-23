<#
    .SYNOPSIS
        Shows named arguments usage
    .DESCRIPTION
        This script is using named arguments and shows, what happens if you pass or omit arguments.

        All variables in param block are assigned values from command line.  You can refer these by using
        -Name value notation, where Name is name of the variable and value is the value assigned.

        The parameter names can be shortened, if the remaining name part is unambiguous.  Or there might be defined
        an alias for parameter name.

        You can assign default value to parameter (like in parameter $Four).  You can always assign another value
        from command line.

        You can also use parameters as unnamed ones.  Then values are assigned to variables sequentially based on
        their position.  This functionality can be turned off with [CmdletBinging] attribute.
    .EXAMPLE
        & '.\02 Named Parameters.ps1' -Four mine -One 1,2,3 -Three something different

        This example uses named parameters by name.  Array of numbers is assigned to variable $One,
        string 'something' to variable $Three and string 'mine' to variable $Four.
        String 'different' is not used, as there is no parameters that could take it.
        Variable $Two is unassigned because it was not used in command line.
    .EXAMPLE
        & '.\02 Named Parameters.ps1' 1,2,3 something different and more

        This example uses named parameters as positional. An array of numbers is assigned to variable $One,
        string 'something' to variable $Two, string 'different' to variable $Three and 'and' to variable $Four.
        If all parameters are positional, the remaining command line arguments are assigned to automatic
        variable $args
    .EXAMPLE
        & '.\02 Named Parameters.ps1' -o 1,2,3 -k something -th different

        This example shows, how parameter names or aliases can be shortened.
    .EXAMPLE
        & '.\02 Named Parameters.ps1' -o 1,2,3 -T something

        This example shows fails, as parameter name -T might be both Two or Three.
    .LINK
        https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parameters
    .LINK
        https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute#positionalbinding
#>

param (
    $One,
        [Alias('Kaks')]
    $Two,
    $Three,
    $Four = 'default value'
)

"The parameter One:"
$One

"`nThe parameter Two:"
$Two

"`nThe parameter Three:"
$Three

"`nThe parameter Four:"
$Four

''
'$args get values that are left over:'
$args
