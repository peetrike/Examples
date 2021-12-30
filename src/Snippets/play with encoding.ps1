
# https://docs.microsoft.com/en-us/dotnet/standard/base-types/character-encoding

$katse = 'ühismääraja mõttetöö'
$katse2 = 'Ã¼hismÃ¤Ã¤raja mÃµttetÃ¶Ã¶'

function ConvertTo-Encoding {
    param (
            [parameter(
                Mandatory,
                ValueFromPipeline
            )]
            [string]
        $text,
            [Text.Encoding]
        $To = [Text.Encoding]::UTF8
    )
    begin {
        $From = [Text.Encoding]::Unicode
    }

    process {
        $bytes = $from.GetBytes($text)
        $NewBytes = [text.encoding]::convert($From, $To, $bytes)
        Write-Verbose -Message ($NewBytes -join ' ')
        [char[]]$NewBytes -join ''
    }
}

function ConvertFrom-Encoding {
    param (
            [parameter(
                Mandatory,
                ValueFromPipeline
            )]
            [string]
        $Text,
            [Text.Encoding]
        $From = [Text.Encoding]::UTF8
    )
    begin {
        $to = [Text.Encoding]::Unicode
    }
    process {
        $bytes = [byte[]]([char[]]$text)
        $NewBytes = [text.encoding]::convert($from, $to, $bytes)
        Write-Verbose -Message ($NewBytes -join ' ')
        $to.GetString($NewBytes)
    }
}

$katse | ConvertTo-Encoding
$katse2 | ConvertFrom-Encoding


$text = 'põlvepööris'
$character = 'õ'
$half = 0xc3
$TagStart = [byte][char]'<'
$vigane = $half, $TagStart

$Utf8Encoding = [Text.Encoding]::UTF8
$Utf7Encoding = [Text.Encoding]::UTF7
$Utf32Encoding = [Text.Encoding]::UTF32
$UnicodeEncoding = [Text.Encoding]::Unicode
$bigEndian = [Text.Encoding]::BigEndianUnicode
$WinDefault = [Text.Encoding]::Default
$WinBaltic = [Text.Encoding]::GetEncoding(1257)
[Text.Encoding]::GetEncodings()

$Utf8Bytes = $Utf8Encoding.GetBytes($character)

$UnicodeEncoding.GetBytes($character)
$bigEndian.GetBytes($character)
$WinDefault.GetBytes($character)

$UnicodeEncoding.GetChars($Utf8Bytes)
$bigendian.GetChars($Utf8Bytes)
$WinDefault.GetChars($Utf8Bytes)
$WinBaltic.GetChars($Utf8Bytes)

$WinBaltic.GetBytes($text)
$WinBaltic.GetChars($WinBaltic.GetBytes($text))

$UnicodeEncoding.GetChars($vigane)
$bigendian.GetChars($vigane)
$Utf8Encoding.GetChars($vigane)
$Utf7Encoding.GetChars($vigane)
$Utf32Encoding.GetChars($vigane)

$WinDefault.CodePage
$Utf8Encoding.CodePage
$Utf7Encoding.CodePage
$bigEndian.CodePage
$UnicodeEncoding.CodePage



# PowerShell 7 and runes

([text.rune]0x1F339).ToString()
"`u{1F339}"

"`u{1F469}"
"`u{1F469}`u{1F3FD}"
$firewoman = "`u{1F469}`u{1F3FD}`u{200D}`u{1F692}"
$bytes = $Utf8Encoding.GetBytes($firewoman)
$Utf8Encoding.GetString($bytes)

$rune1 = [text.rune]0x1F52E
$rune2 = [text.rune]0x10421
$cow = [text.rune]::new(0xd83d, 0xdc02)

$rune1.ToString()
$rune2.ToString()
$cow.ToString()

$asi = [char[]]::new($rune1.Utf16SequenceLength)
$null = $rune2.EncodeToUtf16($asi)
$asi

$byte = [byte[]]::new($rune2.Utf8SequenceLength)
$null = $rune1.EncodeToUtf8($byte)
$byte
