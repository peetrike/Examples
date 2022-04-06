function ConvertTo-Encoding {
    param (
            [parameter(
                Mandatory,
                ValueFromPipeline
            )]
            [string]
        $Text,
            [Text.Encoding]
        $To = [Text.Encoding]::UTF8
    )
    begin {
        $From = [Text.Encoding]::Unicode
    }

    process {
        $bytes = $from.GetBytes($Text)
        $NewBytes = [Text.Encoding]::convert($From, $To, $bytes)
        Write-Verbose -Message ($NewBytes -join ' ')
        [char[]]$NewBytes -join ''
    }
}
