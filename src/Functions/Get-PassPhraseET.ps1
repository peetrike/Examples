<#
    .LINK
        https://www.täringvara.ee/
#>

[CmdletBinding()]
param (
        [ValidateRange(1, 10)]
        [int]
    $Words,
        [ValidateSet('-', '_', '|', '*', '.', ' ')]
        [char]
    $Symbol,
        [switch]
    $Number,
        [switch]
    $Capital
)

function Get-PassPhraseET {
    [CmdletBinding()]
    param (
            [ValidateRange(1, 10)]
            [int]
        $Words = 4,
            [ValidateSet('-', '_', '|', '*', '.', ' ')]
            [char]
        $Symbol = ' ',
            [switch]
        $Number,
            [switch]
        $Capital
    )

    $localFile = "$env:TEMP\Taringvara.txt"
    #$BaseUrl = 'https://raw.githubusercontent.com/KaarelP2rtel/taringvara/master/docs/files/Taringvara.txt'
    #$BaseUrl = 'http://www.täringvara.ee/files/Taringvara.txt'
    $BaseUrl = 'http://www.xn--tringvara-v2a.ee/files/Taringvara.txt'
    if (-not (Test-Path $localfile)) {
        Invoke-WebRequest -Uri $BaseUrl -OutFile $localfile
    }
    $WordList = Get-Content -Path $localFile
    $Selection = $WordList | Where-Object { $_ } | Get-Random -Count $Words
    if ($Number) {
        $i = Get-Random -Maximum ($Words)
        $Selection[$i] += Get-Random -Maximum 10
    }

    if ($Capital) {
        $i = Get-Random -Maximum ($Words)
        $word = $Selection[$i]
        $char = $word[0]
        $Selection[$i] = ([string]$char).ToUpper() + $word.trimstart($char)
    }

    $Selection -join $Symbol
}

Get-PassPhraseET @PSBoundParameters
