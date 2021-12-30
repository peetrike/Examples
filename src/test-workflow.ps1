#Requires -Version 3.0

#region Compacting logs
function compress-log {
    param(
            [string]
        $folder = ".",
            [int]
        $days = 30
    )

    new-alias 7z 'C:\Program Files\7-Zip\7z.exe'
    $firstDate = (get-date) - (New-TimeSpan -Days $days)

    Get-ChildItem -Path $folder -Recurse -File |
        Where-Object { ([datetime]::Now - $_.lastwritetime).Days -gt $days } |
        Foreach-Object {
            & 7z a $("{0:yyyy.MM}.zip" -f $firstDate) $_.FullName
            # Remove-Item $_
        }
}

compress-log -folder u:\katse -days 240


workflow Test-workflow {
    param(
            [string]
        $folder = ".",
            [int]
        $days = 30
    )

        $packer = 'C:\Program Files\7-Zip\7z.exe'
        $firstDate = (get-date) - (New-TimeSpan -Days $days)

        Get-ChildItem -Path $folder -Recurse -File |
            Where-Object -FilterScript { ((get-date) - $_.lastwritetime).Days -gt $days } |
            Foreach-Object {
                & $packer a $("{0:yyyy.MM}.zip" -f $firstDate) $_.FullName
                # Remove-Item $_
            }
}

Test-workflow -folder u:\katse -days 240 #-PSComputerName teinemasin
#endregion

#region Determining local admins
function Get-LocalAdmin {
    net localgroup Administrators |
        Select-Object -Skip 6 |
        Where-Object { $_ -and $_ -notmatch "The command completed successfully" } |
        ForEach-Object {
            $name = $_.split("\")
            $member= New-Object psobject -Property @{ DisplayName=$_; Name=$name[-1]; Domain="" }
            if ($name.length -eq 2) { $member.domain = $name[0] }
            $member
        }
}

Get-LocalAdmin | Format-Table -AutoSize

"server1", "server2" | Out-File servers.txt
$session = New-PSSession -ComputerName (Get-Content .\servers.txt) -Credential domain\user

Invoke-Command -FilePath .\get-localadmin.ps1 -Session $session |
    Select-Object Name, Domain, PSComputerName |
    Group-Object PSComputerName


workflow Test-LocalAdmin {
    net localgroup Administrators |
        Select-Object -Skip 6 |
        Where-Object -FilterScript { $_ -and $_ -notmatch "The command completed successfully" } |
        ForEach-Object {
            $name = $_.split("\")
            $member= New-Object psobject -Property @{ "Name"=$name[-1]; "Domain"="" }
            if ($name.length -eq 2) { $member.domain = $name[0] }
            $member
        }
}

"server1", "server2" | Out-File servers.txt


Test-LocalAdmin <# -PSComputerName (Get-Content .\servers.txt) -PSCredential domain\admin #> |
    Select-Object Name, Domain, PSComputerName |
    Group-Object PSComputerName
#endregion
