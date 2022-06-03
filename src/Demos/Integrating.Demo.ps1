<#
    .SYNOPSIS
        Integrating PowerShell with other applications
    .DESCRIPTION
        This file contains demo transcript from demo that explains
        * how to execute PowerShell from other programs
        * how to run PowerShell code from other programs
        * how to exchange data with PowerShell and other programs
    .NOTES
        Contact: Meelis Nigols
        e-mail/skype: meelisn@outlook.com
    .LINK
        https://github.com/peetrike/examples
#>

#region Safety to prevent the entire script from being run instead of a selection
throw "You're not supposed to run the entire script"
#endregion

#region Calling PowerShell

#region PowerShell command line parameters
powershell.exe -?
pwsh -?

Get-Help about_powershell_exe -ShowWindow
    # requires -Version 7
Get-Help about_pwsh -ShowWindow

#endregion

pwsh -c Write-Output 'tööpäev'

powershell.exe -o xml -c Get-Date

Start-Process -FilePath cmd.exe -ArgumentList '/k', 'powershell', '-c get-date'
Start-Process -FilePath cmd.exe -ArgumentList '/k', 'echo get-date | powershell -c -'

$command = 'dir "c:\program files" '
$bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
$encodedCommand = [Convert]::ToBase64String($bytes)
powershell.exe -encodedCommand $encodedCommand

'get-date', 'whoami' | Set-Content -Path .\commands.ps1 -Encoding utf8
powershell.exe -File .\commands.ps1
pwsh -f commands.ps1

powershell.exe -Command .\commands.ps1

#endregion

#region Calling PowerShell from Powershell

pwsh -c { Write-Output $PSVersionTable.PSVersion }
pwsh -c 'Write-Output $PSVersionTable.PSVersion'
pwsh -c Write-Output $PSVersionTable.PSVersion

$ScriptBlock = { $PSVersionTable.PSVersion }
$version = pwsh -noprofile -c $ScriptBlock
$version.Major

#endregion

#region Running PowerShell code as another user (or admin)

# https://peterwawa.wordpress.com/2010/04/28/powershell-ja-admin-oigused/
Get-Help Start-AsAdmin
Get-Help Start-AsAdmin -Examples

Find-Module -Command Invoke-AsAdmin -Repository PSGallery
Find-Module RunAsUser -Repository PSGallery

# https://gist.github.com/jborean93/33c55bdd47541866dfaea43ab38d2c79

#endregion

#region ExecutionPolicy

Get-ExecutionPolicy -List

Get-Help about_Execution_Policies -ShowWindow

Get-Help Set-ExecutionPolicy

powershell.exe -ExecutionPolicy restricted -c Get-ExecutionPolicy -List

Get-Help Unblock-File -ShowWindow

# https://itwiki.atlassian.teliacompany.net/pages/viewpage.action?pageId=505149033#PowerShelljaturvalisus-ExecutionPolicy(käivituspoliitika)

#endregion

#region Other ways to invoke PowerShell code

Copy-Item -Path .\commands.ps1 -Destination commands.txt
Invoke-Expression (Get-Content .\commands.txt -Raw)
Invoke-Item .\commands.txt
pwsh -c (Get-Content .\commands.txt -Raw)

$Url = 'https://raw.githubusercontent.com/peetrike/Examples/main/src/Gui/OpenFileDialog.ps1'

$content = (Invoke-WebRequest -Uri $url).Content
Invoke-Expression $content

# https://chocolatey.org/install

#endregion


#region Exchanging data with other apps

#region Encoding

Get-Help about_Character_Encoding -ShowWindow

Get-Command -ParameterName Encoding

Get-Help Set-Content -Parameter Encoding
[enum]::GetValues([Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding])


'Tõotus' | Set-Content -Path .\test.txt -Encoding utf8
cmd.exe /c type test.txt
findstr.exe /c:o test.txt

#endregion

#region Getting data through files

Get-Command -Verb Import -Module Microsoft.PowerShell.Utility
Get-Command -Verb ConvertFrom -Module Microsoft.PowerShell.Utility

Get-Command Get-Content

#endregion

#region Outputting data to files

Get-Command -Verb Export -Module Microsoft.PowerShell.Utility
Get-Command -Verb ConvertTo -Module Microsoft.PowerShell.Utility

Get-Command Set-Content, Add-Content

Get-Help ConvertTo-Xml

#endregion

#region Using Pipeline

'Tõotus' | findstr /c:õ
'Tõotus' | findstr /c:o

# https://devblogs.microsoft.com/powershell/outputencoding-to-the-rescue/

$OutputEncoding
[console]::OutputEncoding
[console]::InputEncoding

# https://docs.microsoft.com/dotnet/api/system.console.inputencoding
# https://docs.microsoft.com/dotnet/api/system.console.outputencoding

$OutputEncoding = [console]::OutputEncoding
'Tõotus' | findstr /c:õ


$OutputEncoding = [console]::OutputEncoding = [console]::InputEncoding = [Text.Encoding]::UTF8

#endregion

#region PowerShell streams and external applications
Write-Verbose -Message 'tere' -Verbose
Write-Debug -Message 'tere' -Debug
Write-Warning -Message 'tere'
Write-Error -Message 'tere'

& {
    'ohhoo'
    Write-Warning -Message 'tere'
} > katse.txt
get-content .\katse.txt

Write-Verbose -Message 'tere' -Verbose | findstr /c:e
powershell -noprofile -c Write-Warning -Message 'tere' | findstr /c:e

pwsh -noprofile -c "'ohhoo'; Write-Warning -Message 'tore'" > katse.txt
get-content .\katse.txt

#endregion

#endregion
