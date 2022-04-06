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
        $NewBytes = [Text.Encoding]::convert($From, $to, $bytes)
        Write-Verbose -Message ($NewBytes -join ' ')
        $to.GetString($NewBytes)
    }
}
