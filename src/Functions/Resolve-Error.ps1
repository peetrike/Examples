[CmdletBinding()]
param (
        [System.Management.Automation.ErrorRecord]
    $ErrorRecord = $Error[0]
)

function Resolve-Error {
    [CmdletBinding()]
    param (
            [System.Management.Automation.ErrorRecord]
        $ErrorRecord = $Error[0]
    )

    $ErrorRecord | Format-List * -Force
    $ErrorRecord.InvocationInfo | Format-List *

    $Exception = $ErrorRecord.Exception
    $i = 0
    while ($Exception) {
        "$i" * 80
        $i++
        $Exception | Format-List * -Force
        $Exception = $Exception.InnerException
    }
}

Resolve-Error @PSBoundParameters
