
function get-thing {
    [cmdletbinding()]
    param (
            [parameter(
                ValueFromPipelineByPropertyName
            )]
            [string[]]
        $yks,
            [string[]]
        $kaks
    )

    begin {
        write-verbose 'Alustame'
        'Yks on {0}' -f ($yks -join ',')
    }

    process {
        write-verbose 'protsess'
        'Yks on {0}' -f ($yks -join ',')
    }

    end {
        write-verbose 'Lõpetame'
        'Yks on {0}' -f ($yks -join ',')
    }
}

[PSCustomObject]@{
    yks = 'yks'
}, [PSCustomObject]@{
    yks = 'kaks'
} | get-thing -Verbose
