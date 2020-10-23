<#
    .SYNOPSIS
        Shows how parameters can take values from pipeline using matching property names.
    .DESCRIPTION
        This script demonstrates parameter binding from pipeline by property name.

        The ValueFromPipelineByPropertyName argument specifies, that this parameter will take value from pipeline
        object property that has the name that matches with property name or one of the aliases.

        You can combine ValueFromPipeline and ValueFromPipelineByPropertyName.  If both arguments are present,
        ValueFromPipeline used first, if possible.
    .EXAMPLE
        Get-Service -Name o* | & './12 Pipeline Objects.ps1'

        This example takes pipeline input to parameter Path.
    .EXAMPLE
        Get-ChildItem 12* | & './12 Pipeline Objects.ps1'

        This example will fail as FileInfo objects don't have DisplayName property.
    .LINK
        https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
#>

param (
        [parameter(
            ValueFromPipelineByPropertyName
        )]
        [string]
    $DisplayName
)
process {
    $DisplayName
}
