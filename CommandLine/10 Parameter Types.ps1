<#
    .SYNOPSIS
        Shows several parameter types.
    .DESCRIPTION
        This script shows various parameter types.

        Mandatory parameter needs always value.  If value is not given form command line, it is asked interactively.

        Positional parameter can be picked up without parameter name.  Position starts from 0.  It is recommended
        to always start from position 0 and go forward, to avoid confusion, when parameters are reordered in param
        block.

        Switch parameter has boolean value $true only if it is present on command line.  Omitting it assumes $false
    .EXAMPLE
        & './10 Parameter Types.ps1' -Two 2

        This example shows mandatory parameter.  The value for parameter One is asked interactively.
    .EXAMPLE
        & './10 Parameter Types.ps1' 1 2

        This example shows the usage of positional parameters.  Positional parameter can be used without specifying
        parameter name.
    .EXAMPLE
        & './10 Parameter Types.ps1' -Three -One 1

        This example shows switch parameter.  When switch is used on command line, its value will be $true.
    .LINK
        https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
#>

param (
        [parameter(
            Mandatory,
            Position = 0
        )]
    $One,
        [parameter(Position = 1)]
    $Two,
        [switch]
    $Three
)

'One is:'
$One

if ($Three.IsPresent) {
    'the switch Three was present'
}

if ($Two) {
    'Two:'
    $Two
}
