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
                $Process = [wmi] "Win32_Process.Handle='$Id'"
                [Diagnostics.Process]::GetProcessById($Process.ParentProcessId)
            }
        }
    }
}

process {
    Get-ParentProcess @PSBoundParameters
}
