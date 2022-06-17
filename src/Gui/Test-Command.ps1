<#
    .SYNOPSIS
        Demonstrates Show-Command in the script.
    .DESCRIPTION
        This script demonstrates the use of the Show-Command in the script.
#>

function test-me {
    param (
            [string]
        $One = 'One',
            [string]
        $Two
    )
    $PSBoundParameters
}

Show-Command -Name test-me -PassThru | Invoke-Expression
Show-Command -Name test-me -ErrorPopup
