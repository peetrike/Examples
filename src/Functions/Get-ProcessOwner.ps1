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
    function Get-ProcessOwner {
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

        begin {
            $TypeName = 'ProcessOwner'
        }

        process {
            if ($InputObject) {
                $Id = $InputObject.Id
            }

            $Process = [wmi] "Win32_Process.Handle=$Id"
            $Sid = $Process.GetOwnerSid()
            $Owner = $Process.GetOwner()
            $ResultProps = @{
                Domain = $Owner.Domain
                User   = $Owner.User
                Name   = '{0}\{1}' -f $Owner.Domain, $Owner.User
                Sid    = [Security.Principal.SecurityIdentifier] $Sid.Sid
            }
            if ($useCim) {
                $ResultProps.PSTypeName = $TypeName
                [PSCustomObject] $ResultProps
            } else {
                $result = New-Object -TypeName psobject -Property $ResultProps
                $result.psobject.TypeNames.Insert(0, $TypeName)
                $result
            }
        }
    }
}

process {
    Get-ProcessOwner @PSBoundParameters
}
