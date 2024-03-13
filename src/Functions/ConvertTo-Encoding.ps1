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
        $bytes = $From.GetBytes($Text)
        $NewBytes = [Text.Encoding]::Convert($From, $To, $bytes)
        Write-Verbose -Message ($NewBytes -join ' ')
        [char[]] $NewBytes -join ''
    }
}
