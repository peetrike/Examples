function Get-UserSid {
    [CmdletBinding()]
    param (
            [string]
        $UserName
    )
    if ($UserName) {
        $UserObject = [Security.Principal.NTAccount] $UserName
        $UserObject.Translate([Security.Principal.SecurityIdentifier])
    } else {
        [Security.Principal.WindowsIdentity]::GetCurrent().User
    }
}
