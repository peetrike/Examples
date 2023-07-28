function Read-Choice {
    <#
    .SYNOPSIS
        Uses PromptForChoice host function to ask for choices
    .DESCRIPTION
        This helper function uses interactive choice menu to let user choose the value
    .NOTES
        Choices hashtable will become the choices to choose between.
        Each element's key is used as Label and value is used as HelpMessage.
        Label can contain character '&' to identify the next character in the label as a "hot key".
    .LINK
        https://docs.microsoft.com/dotnet/api/system.management.automation.host.pshostuserinterface.promptforchoice
    .EXAMPLE
        $Choices = @{
            '&one' = 'choice one'
            't&wo' = 'second choice'
        }
        Read-Choice -Message 'please make your choice' -Choice $choices -default 'two'

        This example lets user to choose between 2 choices.
    #>

    [OutputType([string])]
    [CmdletBinding()]
    param (
            [Alias('Caption')]
            [string]
            # Caption to precede or title the prompt
        $Title = 'Choices',
            [string]
            # A message that describes what the choice is for
        $Message = 'Make a choice',
            [Parameter(Mandatory)]
            [Collections.IDictionary]
            # Choices in the form of hashtable.
        $Choices,
            [string]
            # The label of the default value (without hotkey)
        $Default
    )

    $OptionList = foreach ($hash in $Choices.GetEnumerator()) {
        [Management.Automation.Host.ChoiceDescription]::new(
            $hash.Key,  # Label
            $hash.Value # HelpMessage
        )
    }

    $DefaultNumber = -1
    if ($Default) {
        foreach ($item in $OptionList) {
            $DefaultNumber++
            if ($item.Label.Replace('&', '') -eq $Default) { break }
        }
    }

    $result = $host.ui.PromptForChoice(
        $Title,
        $Message,
        $OptionList,
        $DefaultNumber
    )

    $OptionList[$result].Label.Replace('&', '')
}
