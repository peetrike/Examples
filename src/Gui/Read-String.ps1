function Read-String {
    <#
    .SYNOPSIS
        Read-Host with default value
    .DESCRIPTION
        This function asks string input from user with providing default value
    .NOTES

    .LINK
        Read-Host
    .EXAMPLE
        Read-String -Prompt 'Please enter value' -Default 13

        This example asks for input and returns by default provided default value
    #>

    [OutputType([string])]
    [CmdletBinding()]
    param (
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]
            # Specifies the text of the prompt. PowerShell appends a colon (`:`) to the text that you enter.
        $Prompt,
            [string]
            # Specifies default value to return when user doesn't enter anything
        $Default
    )

    if ($Default) {
        $Prompt += ' (default = {0})' -f $Default
    }
    $result = Read-Host -Prompt $Prompt
    if ($result) { $result } else { $Default }
}
