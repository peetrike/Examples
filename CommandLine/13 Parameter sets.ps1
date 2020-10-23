<#
    .SYNOPSIS
        Shows usage of parameter sets.
    .DESCRIPTION
        This script shows the usage of parameter sets.  Parameter sets allow you to specify different sets of
        parameters in the same script.  With this you can make some parameters work separately from others.

        All the parameters used in command line must be from the same parameter set.
    .NOTES
        Be sure that if you use same parameter in several parameter sets, then it is declared with similar
        functionality in all of them.  Otherwise that might lead to confusion.

        The example 5 in this script shows potential problem.  Parameter -Five is declared to take pipeline input
        in one parameter set, but not in another.
    .EXAMPLE
        & './13 Parameter sets.ps1' -One here

        This example uses parameter set One
    .EXAMPLE
        & './13 Parameter sets.ps1' -Two 1,2,3 -Five 5

        This example uses parameter set Two.  It also includes optional parameter Five
    .EXAMPLE
        & './13 Parameter sets.ps1' -One here -Two 1,2,3

        This example will fail because there are used parameters from different parameter sets.
    .EXAMPLE
        'hello there' | & './13 Parameter sets.ps1' -Three 'and here'

        This example uses parameter set Three and takes parameter -Five from pipeline.
    .EXAMPLE
        'hello there' | & './13 Parameter sets.ps1' -Two 'and here'

        This example fails, because in parameter set Two parameter -Five will not get value from pipeline.  And
        there is no other parameter to put pipeline input.  As the error is non-terminating, the script still
        continues.
    .EXAMPLE
        & './13 Parameter sets.ps1' -Four

        This example uses Default parameter set as there are not possible to determine parameterset from parameters
    .LINK
        https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parameter_sets
#>

[CmdletBinding(
    DefaultParameterSetName = 'One'
)]
param (
        [parameter(
            ParameterSetName = 'One'
        )]
    $One,
        [parameter(
            Mandatory,
            ParameterSetName = 'Two'
        )]
    $Two,
        [Parameter(
            Mandatory,
            ParameterSetName = 'Three'
        )]
    $Three,
        [switch]
    $Four,
        [Parameter(
            ParameterSetName = 'Two'
        )]
        [Parameter(
            ParameterSetName = 'Three',
            ValueFromPipeline
        )]
    $Five
)

if ($Three.IsPresent) {
    'The parameter Three is present'
}

switch ($PSCmdlet.ParameterSetName) {
    'One' {
        'ParameterSet One'
        $One
    }
    'Two' {
        'Another ParameterSet (Two)'
        $Two
        'Optional parameter: ' + $Five
    }
    Default {
        'yet another ParameterSet: {0}' -f $PSCmdlet.ParameterSetName
        $Five
        $Three
    }
}

'Common parameter "Four": ' + $Four
