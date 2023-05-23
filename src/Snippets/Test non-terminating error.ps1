
# how to stop processing current item in pipeline without breaking whole pipeline

[CmdletBinding()]
param ()

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
            if ($test -like 'Break') {
                break
            } elseif ($test -like 'Continue') {
                continue
            } else { return }
        } else { $Asi }
        Write-Verbose -Message 'ending processing pipe'
    }
}

'yks', 'kaks', 'kolm' | test-asi -Test Return | foreach { @{ Väärtus = $_} }
'yks', 'kaks', 'kolm' | test-asi -Test Break | foreach { @{ Väärtus = $_} }
'yks', 'kaks', 'kolm' | test-asi -Test Continue | foreach { @{ Väärtus = $_} }
