function Get-RandomString {
    [OutputType([string])]
    [CmdletBinding()]
    param (
            [ValidateRange(4, 128)]
            [int]
        $Length = 15,
            [ValidatePattern('\d')]
            [char[]]
        $Number = ('23456789'.ToCharArray()),
            [ValidatePattern('[a-z]')]
            [char[]]
        $Letter = ('abcdefghijkmnpqrstuvwxyz'.ToCharArray()),
            [char[]]
            [ValidatePattern('[A-Z]')]
        $Capital = ('ABCDEFGHJKLMNPRSTUVWXYZ'.ToCharArray()),
            [char[]]
        $Symbol = ('!#%+@:=?*'.ToCharArray())
    )

    $table = @{
        Capital = $Capital
        Letter  = $Letter
        Number  = $Number
        Symbol  = $Symbol
    }
    $AllSymbol = $Number + $Letter + $Capital + $Symbol

    [char[]] $everySet = foreach ($key in $table.Keys | Get-Random -Count 4) {
        Get-Random -InputObject $table.$key
    }
    [char[]] $allSet = for ($i = 5; $i -le $Length; $i++) { Get-Random -InputObject $AllSymbol }

    $builder = [System.Text.StringBuilder] $Length
    [void] $builder.Append($allSet)
    [void] $builder.Append($everySet)
    $builder.ToString()
}

function Get-RandomString1 {
    [OutputType([string])]
    [CmdletBinding()]
    param (
            [ValidateRange(4, 128)]
            [int]
        $Length = 15,
            [char[]]
        $Number = ('23456789'.ToCharArray()),
            [char[]]
        $Letter = ('abcdefghijkmnpqrstuvwxyz'.ToCharArray()),
            [char[]]
        $Capital = ('ABCDEFGHJKLMNPRSTUVWXYZ'.ToCharArray()),
            [char[]]
        $Symbol = ('!#%$/+@:=?*'.ToCharArray())
    )

    $table = @{
        Capital = $Capital
        Letter  = $Letter
        Number  = $Number
        Symbol  = $Symbol
    }
    $AllSymbol = $Number + $Letter + $Capital + $Symbol

    [char[]] $everySet = foreach ($key in $table.Keys | Get-Random -Count 4) { Get-Random -InputObject $table.$key }
    [char[]] $allSet = for ($i = 5; $i -le $Length; $i++) {
        Get-Random -InputObject $AllSymbol
    }
    [int] $half = [math]::Round($allset.Count / 2)

    $builder = [System.Text.StringBuilder] $Length
    if ($half -gt 0) { [void] $builder.Append($allSet, 0, $half) }
    [void] $builder.Append($everySet)
    if ($length -gt 4) { [void] $builder.Append($allSet, $half, $allSet.Count - $half) }
    $builder.ToString()
}

function Get-RandomStringArray {
    [OutputType([string])]
    [CmdletBinding()]
    param (
            [ValidateRange(4, 128)]
            [int]
        $Length = 15,
            [char[]]
        $Number = ('23456789'.ToCharArray()),
            [char[]]
        $Letter = ('abcdefghijkmnpqrstuvwxyz'.ToCharArray()),
            [char[]]
        $Capital = ('ABCDEFGHJKLMNPRSTUVWXYZ'.ToCharArray()),
            [char[]]
        $Symbol = ('!#%$/+@:=?*'.ToCharArray())
    )

    $table = @{
        Capital = $Capital
        Letter  = $Letter
        Number  = $Number
        Symbol  = $Symbol
    }
    $AllSymbol = $Number + $Letter + $Capital + $Symbol

    -join @(
        for ($i = 5; $i -le $Length; $i++) {
            Get-Random -InputObject $AllSymbol
        }
        foreach ($key in $table.Keys | Get-Random -Count 4) { Get-Random -InputObject $table.$key }
    )
}

function Get-RandomStringRandom {
    [OutputType([string])]
    [CmdletBinding()]
    param (
            [ValidateRange(4, 128)]
            [int]
        $Length = 15,
            [char[]]
        $Number = ('23456789'.ToCharArray()),
            [char[]]
        $Letter = ('abcdefghijkmnpqrstuvwxyz'.ToCharArray()),
            [char[]]
        $Capital = ('ABCDEFGHJKLMNPRSTUVWXYZ'.ToCharArray()),
            [char[]]
        $Symbol = ('!#%$/+@:=?*'.ToCharArray())
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

function Get-RandomStringOld {
    [OutputType([string])]
    param(
            [int]
        $Length = 15,
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

function Get-RandomStringOldest {
    param(
        [Int]$Length = 15,
        $Number  = ((48..57)  | ForEach-Object {  [char]$_}),
        $Letter  = ((97..122) | ForEach-Object {  [char]$_}),
        $Capital = ((65..90)  | ForEach-Object {  [char]$_}),
        $Symbol  = ((33,35,36,37,40,41,43,45,46,58,64) | ForEach-Object {  [char]$_})
    )

    [String]$Password = $null

    $Character = $Number + $Letter + $Capital + $Symbol
    $List = 'Number','Letter','Capital','Symbol' | Sort-Object {Get-Random}

    foreach ($l in $List) {
        $Value = Get-Variable $l -ValueOnly
        if ($Value) {
            $Password += Get-Random -InputObject $Value
        }
    }

    do {
        $Password += Get-Random -InputObject $Character
    } while ( $Password.Length -lt $Length )

    $Password
}

$Iterations = 1000

$Technique = @{
    'Current'     = { Get-RandomString -Length $length }
    'New'         = { Get-RandomString1 -Length $length }
    'Array'       = { Get-RandomStringArray -Length $length }
    'Random'      = { Get-RandomStringRandom -Length $length }
    'Oldest 2020' = { Get-RandomStringOldest -Length $length }
    'Old 2024'    = { Get-RandomStringOld -Length $length }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    foreach ($length in 4, 15, 20, 64, 128) {
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
