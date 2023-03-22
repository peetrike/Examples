# get PowerShell remote sessions currently available

function Get-PSRemoteSession {
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param ()

    $UserTypeName = 'User'
    if (-not (Get-TypeData -TypeName $UserTypeName)) {
        Update-TypeData -TypeName $UserTypeName -MemberName ToString -MemberType ScriptMethod -Value { $this.Name }
    }

    Get-WSManInstance -ResourceURI shell -Enumerate | ForEach-Object {
        $Session = $_

        $UserName = $Session.Owner
        $NamePart = $UserName -split '\\'
        $UserObject = [Security.Principal.NTAccount] $UserName
        $UserProps = @{
            PSTypeName = $UserTypeName
            Domain     = $NamePart[0]
            User       = $NamePart[1]
            Name       = $UserName
            Sid        = $UserObject.Translate([Security.Principal.SecurityIdentifier])
        }

        $ResultProps = @{
            PSTypeName   = 'PowerShell.RemoteSession'
            Id           = [guid] $Session.ShellId
            IP           = [ipaddress] $Session.ClientIp
            Process      = Get-Process -id $Session.ProcessId
            SessionConfiguration = ($Session.ResourceUri -split '/')[-1]
            State        = $Session.State
            IdleTime     = [Xml.XmlConvert]::ToTimeSpan($Session.ShellInactivity)
            RunTime      = [Xml.XmlConvert]::ToTimeSpan($Session.ShellRunTime)
            User         = [PSCustomObject] $UserProps
        }
        [PSCustomObject] $ResultProps
    }
}
