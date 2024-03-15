[CmdletBinding(
    DefaultParameterSetName = 'Default'
)]
param (
        [ValidateSet('plain', 'json', 'xml')]
        [string]
    $Type = 'plain',
        [uint16]
    $MaxLength = 63,
        [ValidateRange(1, 50)]
        [int]
    $Count,
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [ValidateRange(1, 16)]
        [int]
    $Words,
        [Parameter(
            ParameterSetName = 'Readable'
        )]
        [switch]
    $Readable,
        [switch]
    $Number,
        [switch]
    $Capital
)

function New-PassPhrase {
    <#
        .LINK
            https://makemeapassword.ligos.net/api
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Default'
    )]
    param (
            [ValidateSet('plain', 'json', 'xml')]
            [string]
        $Type = 'plain',
            [uint16]
        $MaxLength = 63,
            [ValidateRange(1, 50)]
            [int]
        $Count,
            [Parameter(
                ParameterSetName = 'Default'
            )]
            [ValidateRange(1, 16)]
            [int]
        $Words,
            [Parameter(
                ParameterSetName = 'Readable'
            )]
            [switch]
        $Readable,
            [switch]
        $Number,
            [switch]
        $Capital
    )

    $BaseUrl = 'https://makemeapassword.ligos.net/api/v1'
    $Style = 'passphrase'
    if ($Readable) { $Style = 'readable' + $Style }
    $requestUrl = $BaseUrl, $Style, $Type -join '/'

    $props = @{
        maxCh = $MaxLength
    }

    if ($Count) {
        $props.pc = $Count
    }
    if ($Number) {
        $props.nums = 1
        $props.whenNum = 'StartOrEndOfWord'
    }
    if ($Capital) {
        $props.ups = 1
        $props.whenUp = 'StartOfWord'
    }

    if ($Words) {
        $props.wc = $Words
    }

    Invoke-RestMethod -Uri $requestUrl -Body $props
}

New-PassPhrase @PSBoundParameters
