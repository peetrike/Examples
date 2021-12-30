function Get-SidIdentity {
    [CmdletBinding()]
    param (
            [parameter(
                ValueFromPipeline
            )]
            [Security.Principal.SecurityIdentifier]
        $Sid = [Security.Principal.WindowsIdentity]::GetCurrent().User
    )

    process {
        $Sid.Translate([Security.Principal.NTAccount]).Value
    }
}
