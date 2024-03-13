function Get-CurrentUser {
    [OutputType([Security.Principal.WindowsIdentity])]
    [CmdletBinding()]
    param ()

    [Security.Principal.WindowsIdentity]::GetCurrent()
}
