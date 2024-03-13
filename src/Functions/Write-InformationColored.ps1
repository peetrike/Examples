#Requires -Version 5.0

function Write-InformationColored {
    <#
        .SYNOPSIS
            Writes messages to the information stream, optionally with
            color when written to the host.

        .DESCRIPTION
            An alternative to Write-Host which will write to the information stream
            and the host (optionally in colors specified) but will honor the
            $InformationPreference of the calling context.

            In PowerShell 5.0+ Write-Host calls through to Write-Information but
            will _always_ treats $InformationPreference as 'Continue', so the caller
            cannot use other options to the preference variable as intended.

        .NOTES
            taken from https://gist.github.com/Kieranties/90ff3b32f4645577a1f201f3092300bd
    #>

    [OutputType([Management.Automation.InformationRecord])]
    [CmdletBinding()]
    param (
            [Parameter(Mandatory)]
            [Object]
        $MessageData,
            [ConsoleColor]
        $ForegroundColor = $Host.UI.RawUI.ForegroundColor, # Make sure we use the current colours by default
            [ConsoleColor]
        $BackgroundColor = $Host.UI.RawUI.BackgroundColor,
            [Switch]
        $NoNewline
    )

    $msg = [Management.Automation.HostInformationMessage] @{
        Message         = $MessageData
        ForegroundColor = $ForegroundColor
        BackgroundColor = $BackgroundColor
        NoNewline       = $NoNewline
    }

    Write-Information -MessageData $msg
}
