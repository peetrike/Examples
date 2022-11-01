#Requires -Version 3

[CmdletBinding(
    DefaultParameterSetName = 'ById'
)]
param (
        [Parameter(
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

begin {
    function Get-ParentProcess {
        [CmdletBinding(
            DefaultParameterSetName = 'ById'
        )]
        param (
                [Parameter(
                    ParameterSetName = 'ById'
                )]
                [int]
            $Id = $PID,
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
}

process {
    Get-ParentProcess @PSBoundParameters
}
