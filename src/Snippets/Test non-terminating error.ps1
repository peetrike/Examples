
# how to stop processing current item in pipeline without breaking whole pipeline

function test-asi {
    [CmdletBinding()]
    param (
            [Parameter(
                ValueFromPipeline
            )]
            [string]
        $Asi,
            [ValidateSet(
                'Break',
                'Continue',
                'Return'
            )]
            [string]
        $Test
    )

    process {
        if ($asi -like 'kaks') {
            write-error -Message 'Kaks pole lubatud'
            switch ($test) {
                'break' { break }
                'continue' { continue }
                'return' { return }
            }
        } else { $Asi }
        Write-Verbose -Message 'ending processing pipe'
    }
}

'yks', 'kaks', 'kolm' | test-asi -Test Return | foreach { @{ Väärtus = $_} }
