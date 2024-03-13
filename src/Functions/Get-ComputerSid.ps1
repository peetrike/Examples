function Get-ComputerSid {
    [CmdletBinding()]
    param ()

    try {
        (Get-LocalUser -ErrorAction Stop | Select-Object -First 1).Sid.AccountDomainSid
    } catch {
        $Object = ([wmisearcher] 'SELECT * FROM Win32_UserAccount WHERE LocalAccount=True').Get() |
            Select-Object -First 1

        ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
    }
}
