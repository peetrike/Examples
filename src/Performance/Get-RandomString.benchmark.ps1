function Get-RandomString1 {
    [OutputType([string])]
    param(
            [ValidateScript({ $_ -gt 4 })]
            [int]
        $Length = 8,
            [char[]]
        $Number = (48..57 | ForEach-Object { [char]$_ }),
            [char[]]
        $Letter = (97..122 | ForEach-Object { [char]$_ }),
            [char[]]
        $Capital = (65..90 | ForEach-Object { [char]$_ }),
            [char[]]
        $Symbol = (33, 35, 36, 37, 40, 41, 43, 45, 46, 58, 64 | ForEach-Object { [char]$_ })
    )

    $table = @{
        Capital = $Capital
        Letter  = $Letter
        Number  = $Number
        Symbol  = $Symbol
    }
    $AllSymbol = $Number + $Letter + $Capital + $Symbol

    $Array = @(
        foreach ($key in $table.Keys) { Get-Random -InputObject $table.$key }

        for ($i = 5; $i -le $Length; $i++) {
            Get-Random -InputObject $AllSymbol
        }
    ) | Get-Random -Count $Length
    -join $Array
}

function Get-RandomString2 {
    [OutputType([string])]
    param(
            [ValidateScript({ $_ -gt 4 })]
            [int]
        $Length = 8,
            [char[]]
        $Number = (48..57 | ForEach-Object { [char]$_ }),
            [char[]]
        $Letter = (97..122 | ForEach-Object { [char]$_ }),
            [char[]]
        $Capital = (65..90 | ForEach-Object { [char]$_ }),
            [char[]]
        $Symbol = (33, 35, 36, 37, 40, 41, 43, 45, 46, 58, 64 | ForEach-Object { [char]$_ })
    )

    $table = @{
        Capital = $Capital
        Letter  = $Letter
        Number  = $Number
        Symbol  = $Symbol
    }
    $AllSymbol = $Number + $Letter + $Capital + $Symbol

    -join @(
        foreach ($key in $table.Keys | Get-Random -Count 4) { Get-Random -InputObject $table.$key }

        for ($i = 5; $i -le $Length; $i++) {
            Get-Random -InputObject $AllSymbol
        }
    )
}

function Get-RandomString {
    [OutputType([string])]
    param(
            [ValidateScript({ $_ -gt 4 })]
            [int]
        $Length = 8,
            [char[]]
        $Number  = (48..57 | ForEach-Object { [char]$_ }),
            [char[]]
        $Letter  = (97..122 | ForEach-Object { [char]$_ }),
            [char[]]
        $Capital = (65..90 | ForEach-Object { [char]$_ }),
            [char[]]
        $Symbol  = (33, 35, 36, 37, 40, 41, 43, 45, 46, 58, 64 | ForEach-Object { [char]$_ })
    )

    [String] $Password = ''

    $Character = $Number + $Letter + $Capital + $Symbol
    $List = 'Number', 'Letter', 'Capital', 'Symbol' | Sort-Object { Get-Random }

    foreach ($l in $List) {
        $Value = Get-Variable $l -ValueOnly
        if ($Value) {
            $Password += Get-Random -InputObject $Value
        }
    }

    do {
        $Password += Get-Random -InputObject $Character
    }
    while ( $Password.Length -lt $Length )

    $Password
}

$Iterations = 1000

$Technique = @{
    'Original'  = { Get-RandomString -Length $length }
    'NewRandom' = { Get-RandomString1 -Length $length }
    'New'       = { Get-RandomString2 -Length $length }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    foreach ($length in 5, 10, 18, 64, 128) {
        Measure-Benchmark -Technique $Technique -RepeatCount $Iterations -GroupName "Length $length "
    }
} else {
    $length = 128
    $Max = $Iterations
    Write-Verbose -Message ('PowerShell 2: {0} times' -f $Max)
    Import-Module .\measure.psm1

    foreach ($t in $Technique.Keys) {
        Measure-ScriptBlock -Method $t -Iterations $Max -ScriptBlock $Technique.$t
    }
}
