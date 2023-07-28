function Read-String {
    [OutputType([string])]
    [CmdletBinding()]
    param (
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]
        $Prompt,
            [string]
        $Default
    )

    if ($Default) {
        $Prompt += ' (default = {0})' -f $Default
    }
    $result = Read-Host -Prompt $Prompt
    if ($result) { $result } else { $Default }
}
