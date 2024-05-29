function New-RandomString {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Int32[]]
        $Length = @(16..20),

        [System.Char[]]
        $Number  = (48..57 | ForEach-Object { [char] $_ }),

        [System.Char[]]
        $Letter  = (97..122 | ForEach-Object { [char] $_ }),

        [System.Char[]]
        $Capital = (65..90 | ForEach-Object { [char] $_ }),

        [System.Char[]]
        $Symbol  = (33, 35, 36, 37, 40, 41, 43, 45, 46, 58, 64 | ForEach-Object { [char] $_ }),

        [System.Char[]]
        $Exclude,

        [ValidateSet('Capital','Letter','Number','Symbol')]
        [String[]]
        $Use
    )

    process {

        $CharTable = @{
            Capital = $Capital.Where({$_ -notin $Exclude})
            Letter = $Letter.Where({$_ -notin $Exclude})
            Number = $Number.Where({$_ -notin $Exclude})
            Symbol = $Symbol.Where({$_ -notin $Exclude})
        }

        $UseCharacterType = $Use + $PSBoundParameters.Keys.Where({$_ -in $CharTable.Keys}) | Sort-Object -Unique
        if (-not $UseCharacterType) {$UseCharacterType = $CharTable.Keys}
        $UseCharacter = $CharTable[$UseCharacterType].ForEach({$_})

        $StringLength = $Length | Get-Random

        if ($StringLength -gt $UseCharacter.Count) {
            $UseCharacter = $UseCharacter * [System.Math]::Ceiling($StringLength / $UseCharacter.Count)
        }

        $StringChar = @($UseCharacterType.ForEach({$CharTable[$_] | Get-Random -Count 1}))

        if ($StringLength -gt $StringChar.Count) {
            $StringChar += $UseCharacter | Get-Random -Count ($StringLength - $StringChar.Count)
        }
        else {
            $StringChar = $StringChar | Get-Random -Count $StringLength
        }

        $StringChar = $StringChar | Get-Random -Count $StringChar.Count

        if ($PSCmdlet.ShouldProcess(
            'random string with length {0}' -f $StringLength,
            'Use character {0}' -f ($CharTable[$UseCharacterType].ForEach({$_}) -join ''))
            ) {

            [String]::new($StringChar)
        }
    }
}
