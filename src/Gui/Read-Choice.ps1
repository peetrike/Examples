function Read-Choice {
    <#
        .SYNOPSIS
            Uses PromptForChoice host function to ask for choices
        .DESCRIPTION
            This helper function uses interactive choice menu to let user choose the value
        .NOTES
            Choices dictionary will become the choices to choose between.
            Each element's Key is used as Label and Value is used as HelpMessage.
            Label can contain character '&' to identify the next character in the label as a "hot key".
        .LINK
            https://learn.microsoft.com/dotnet/api/system.management.automation.host.pshostuserinterface.promptforchoice
        .EXAMPLE
            $Choice = @{
                '&one' = 'choice one'
                't&wo' = 'second choice'
            }
            Read-Choice -Message 'please make your choice' -Choices $Choice -default 'two'

            This example lets user to choose between 2 choices.
        .EXAMPLE
            $Choice = [ordered] @{
                '&one' = 'choice one'
                't&wo' = 'second choice'
            }
            Read-Choice -Message 'please make your choice' -Choices $Choice -default 'two'

            This example uses OrderedDictionary to maintain choices order.
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
            # Choices in the form of hashtable or OrderedDictionary.
        $Choices,
            [string]
            # The label of the default value (without hotkey)
        $Default
    )

    $OptionList = foreach ($hash in $Choices.GetEnumerator()) {
        New-Object -TypeName Management.Automation.Host.ChoiceDescription -ArgumentList @(
            $hash.Key   # Label
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
