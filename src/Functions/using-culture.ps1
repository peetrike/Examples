Function Using-Culture {
    param (
            [parameter(
                Mandatory
            )]
            [System.Globalization.CultureInfo]
        $culture,
            [parameter(
                Mandatory
            )]
            [ScriptBlock]
        $ScriptBlock
    )

    $OldCulture = [System.Threading.Thread]::CurrentThread.CurrentCulture

    try {
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture
        Invoke-Command $ScriptBlock
    } finally {
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture
    }
}
