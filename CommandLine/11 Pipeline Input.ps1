<#
    .SYNOPSIS
        Shows how parameters can take values from pipeline.
    .DESCRIPTION
        This script demonstrates parameter binding from pipeline.

        The ValueFromPipeline argument specifies, that this parameter will take value from pipeline.

        If there are more than one such parameter, the one that matches pipeline input datatype, will be used.

        It is common that if parameter is included solely for taking input from pipeline, its name is InputObject
    .NOTES
        You need to use process {} block to process pipeline input.
    .EXAMPLE
        Get-ChildItem -Path .. -Directory | & './11 Pipeline Input.ps1'

        This example takes pipeline input to parameter Path.
    .EXAMPLE
        1,2,3 | & './11 Pipeline Input.ps1'

        This example takes pipeline input to parameter One.
    .LINK
        https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
#>

param (
        [parameter(
            ValueFromPipeline
        )]
        [System.IO.DirectoryInfo]
    $Path,
        [parameter(
            ValueFromPipeline
        )]
        [int]
    $One,
        [string]
    $Two
)

process {
    if (Test-Path -Path $path) {
        'Path:'
        $Path
    }

    if ($One) {
        "`nInputObject:"
        $One
    }
}
