[CmdletBinding()]
param (
        [ValidateSet(
            'exit',
            'throw'
        )]
        [string]
    $Action = 'exit'
)

switch ($Action) {
    'exit' {
        Write-Host -ForegroundColor Red 'Exiting'
        exit 1
    }
    'throw' {
        throw 'Error'
    }
}
