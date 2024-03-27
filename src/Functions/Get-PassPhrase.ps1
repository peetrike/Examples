<#
    .LINK
        https://www.getpassphrase.app/blogs/api
#>

[CmdletBinding()]
param (
        [ValidateRange(1, 10)]
        [int]
    $Words,
        [ValidateSet('-', '_', '|', '*', '.')]
        [char]
    $Symbol,
        [switch]
    $Number,
        [switch]
    $Capital
)

function Get-PassPhrase {
    [CmdletBinding()]
    param (
            [ValidateRange(1, 10)]
            [int]
        $Words,
            [ValidateSet('-', '_', '|', '*', '.')]
            [char]
        $Symbol,
            [switch]
        $Number,
            [switch]
        $Capital
    )

    $BaseUrl = 'https://api.getpassphrase.app/generate'
    $Properties = @{}
    if ($Words) {
        $Properties['totalWords'] = $Words
    }
    if ($Symbol) {
        $Properties['symbol'] = $Symbol
    }
    if ($Number) {
        $Properties['includeNumber'] = 'true'
    }
    if ($Capital) {
        $Properties['isCapital'] = 'true'
    }
    Write-Debug -Message ($Properties | ConvertTo-Json)
    $Result = Invoke-RestMethod -uri $BaseUrl -Body $Properties
    $Result.passphrase
}

Get-PassPhrase @PSBoundParameters
