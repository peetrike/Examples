#Requires -Version 2

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
            Mandatory = $true,
            ParameterSetName = 'Pipe',
            ValueFromPipeline = $true
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
                    Mandatory = $true,
                    ParameterSetName = 'Pipe',
                    ValueFromPipeline = $true
                )]
                [Diagnostics.Process]
            $InputObject
        )

        process {
            if ($InputObject) {
                $Id = $InputObject.Id
            } else {
                $InputObject = Get-Process -Id $Id
            }

            if ($InputObject.Parent) {
                $InputObject.Parent
            } else {
                $Process = if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
                    Get-CimInstance -ClassName Win32_Process -Filter "ProcessId=$Id"
                } else {
                    Get-WmiObject -Class Win32_Process -Filter "ProcessId=$Id"
                }
                Get-Process -Id $Process.ParentProcessId
            }
        }
    }
}

process {
    Get-ParentProcess @PSBoundParameters
}
