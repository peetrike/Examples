function Remove-JsonComment {
    param(
            [Parameter(
                Mandatory = $true,
                ValueFromPipeline = $true
            )]
            [string]
        $Line
    )

    process {
        $line -replace '//.*' -replace '/\\*.*?\\*/'
    }
}
