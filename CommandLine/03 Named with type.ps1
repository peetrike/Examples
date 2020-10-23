<#
    .SYNOPSIS
        Shows named arguments with data types usage
    .DESCRIPTION
        This script is using named arguments with data types.
        If you omit datatype, then parameters work as all variables in Powershell: they can take any type of data.
    .EXAMPLE
        & '.\03 Named with type.ps1' -One 1,2,3 -Two hello -Three (Get-ChildItem readme.md -File)

        Will assign array of numbers into variable $One, string 'there' to variable $Two and
        file object (readme.md) to variable $Three.
    .EXAMPLE
        & '.\03 Named with type.ps1' -One something

        This example will fail because parameter $One value (string 'something') cannot be converted to required
        datatype (integer array).
#>

param (
        [int[]]
    $One,
    $Two,
    $Three
)

'$One datatype: {0}' -f $One.GetType()
"The parameter one:"
$One

''
'$Two datatype: {0}' -f $Two.GetType()
"The parameter two:"
$Two

''
'$Three datatype: {0}' -f $Three.GetType()
"The parameter three:"
$Three
