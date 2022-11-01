#Requires -Version 3

[CmdletBinding()]
param (
        [Parameter(
            Mandatory,
            ParameterSetName = 'ById'
        )]
        [int]
    $Id,
        [Parameter(
            Mandatory,
            ParameterSetName = 'Pipe',
            ValueFromPipeline
        )]
        [Diagnostics.Process]
    $InputObject
)

function Get-ParentProcess {
    [CmdletBinding()]
    param (
            [Parameter(
                Mandatory,
                ParameterSetName = 'ById'
            )]
            [int]
        $Id,
            [Parameter(
                Mandatory,
                ParameterSetName = 'Pipe',
                ValueFromPipeline
            )]
            [Diagnostics.Process]
        $InputObject
    )

    process {
        if ($InputObject) {
            $Id = $InputObject.Id
        }

        $Process = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId=$Id"
        Get-Process -Id $Process.ParentProcessId
    }
}

Get-ParentProcess @PSBoundParameters
