<#
    .SYNOPSIS
        Shows how -Whatif and -Confirm support can be added
    .DESCRIPTION
        This examples shows how to add -Whatif and -Confirm parameters to your own script.

    .EXAMPLE
        Get-ChildItem | & './14 Whatif and Confirm.ps1' -Whatif

        This example just show's what can happen if you run the same command line without -Whatif switch
    .EXAMPLE
        Get-ChildItem | & './14 Whatif and Confirm.ps1' -Confirm

        This example asks for confirmation for each object that comes from pipeline.
    .EXAMPLE
        Get-ChildItem | & './14 Whatif and Confirm.ps1' -Verbose

        This example shows that ShouldProcess parameters are also used for verbose output.
    .LINK
        https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute
    .LINK
        https://docs.microsoft.com/dotnet/api/system.management.automation.cmdlet.shouldprocess
#>

[CmdletBinding(
    SupportsShouldProcess
)]
param (
        [parameter(
            ValueFromPipeline
        )]
    $InputObject
)

process {
    if ($PSCmdlet.ShouldProcess($InputObject, 'Try to remove')) {
        'not really removing: {0}' -f $InputObject
    }
}
