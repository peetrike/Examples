function Get-CurrentUser {
    [CmdletBinding()]
    param ()

    [Security.Principal.WindowsIdentity]::GetCurrent()
}
