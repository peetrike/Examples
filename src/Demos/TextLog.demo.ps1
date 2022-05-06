<#
    .SYNOPSIS
        Text-based log processing demo
    .DESCRIPTION
        This file contains demo transcript from
        text-based log processing demo
    .NOTES
        Contact: Meelis Nigols
        e-mail/skype: meelisn@outlook.com
    .LINK
        https://github.com/peetrike/examples
#>

#region Safety to prevent the entire script from being run instead of a selection
throw "You're not supposed to run the entire script"
#endregion

#region Possible ways to process text files

Get-Command -Noun Content

Get-Command -Verb Import -Module Microsoft.PowerShell.Utility
Get-Command -Verb ConvertFrom -Module Microsoft.PowerShell.Utility

#endregion

#region Using XML log files

$XmlContent = [xml] (Get-Content mylog.xml)
    # use XPath filtering to get relevant data
$XmlContent.SelectNodes('//data')

#endregion

#region Using JSON log files

$JsonContent = Get-Content mylog.json | ConvertFrom-Json

$JsonContent | Where-Object Name -like 'myData'

#endregion

#region (ab)Using CSV log files

$MyData = Import-Csv mylog.txt

Get-Help Import-Csv

$header = 'first, second, third'
$MyData = Import-Csv mylog.txt -Header $header
    #alternate way
$MyData = @(
    $header
    Get-Content mylog.txt
) | ConvertFrom-Csv

# Estonian regional settings
$MyData = Import-Csv mylog.txt -UseCulture
$MyData = Import-Csv mylog.txt -Delimiter ';'

Get-Help import-csv -Parameter Encoding
    # this is for PowerShell 7
$MyData = Import-Csv mylog.txt -UseCulture -Encoding utf8BOM

Get-Help Import-Csv -Parameter Delimiter
Import-Csv mylog.txt -Delimiter "`t"

#endregion

#region Searching from text files

Get-help Select-String

Select-String -Pattern '^#' -Path *.txt

    #multiline log files
Get-Help Select-String -Parameter Context

$found = Select-String -Pattern '^#' -Path *.txt -Context 0, 2
$found | Get-Member

(Get-Help Select-String).examples.example[7]

# https://peterwawa.wordpress.com/2011/12/13/vikesed-asjad-vrgus/
#Requires RunAsAdministrator
netstat.exe -abno |
    Select-String ':3389 ' -Context 0, 1 |
    Where-Object { $_.line -like '*listening*' }

#endregion

#region Converting text file with loose structure to array of objects
#Requires -Version 5.0

Get-Help ConvertFrom-String
Get-Help ConvertFrom-String -Examples

Get-Help ConvertFrom-String -Parameter Delimiter
    # this is the actual default delimiter
$myData = Get-Content myfile.log | ConvertFrom-String -Delimiter '\s+'

"tere tulemast" | ConvertFrom-String
"tere `t tulemast" | ConvertFrom-String
"tere `t tulemast" | ConvertFrom-String -PropertyNames 'yks', 'kaks'

# https://peterwawa.wordpress.com/2011/12/13/vikesed-asjad-vrgus/
function Get-PortProcess {
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, 65535)]
        [int[]]
      $Port
    )

    netstat -ano |
        select-string ($(foreach ($p in $Port) {':{0} ' -f $p}) -join '|') |
        select-string 'listening' |
        ConvertFrom-String -PropertyNames Empty,
            Protocol, LocalAddress, RemoteAddress, State, ProccessId |
        ForEach-Object {
            $row = $_
            Get-Process -Id $_.ProccessId |
                Add-Member -NotePropertyName Port -NotePropertyValue ([int]$row.LocalAddress.split(':')[-1]) -PassThru |
                Select-Object -Property Port, Processname, Path
        } |
        Sort-Object -Property Port -Unique
}
#Requires RunAsAdministrator
Get-PortProcess -Port 3389, 5985

    # or https://docs.microsoft.com/powershell/module/microsoft.powershell.utility/convertfrom-string#example-4-use-an-expression-as-the-value-of-the-templatecontent-parameter-save-the-results-in-a-variable
(Get-Help ConvertFrom-String).examples.example[4]
    # https://docs.microsoft.com/powershell/module/microsoft.powershell.utility/convertfrom-string#example-5-specifying-data-types-to-the-generated-properties
(Get-Help ConvertFrom-String).examples.example[5]

# https://bitbucket.atlassian.teliacompany.net/projects/PWSH/repos/klh-netbackup/browse/src/Start-BackupMonitor.ps1
# https://bitbucket.atlassian.teliacompany.net/projects/PWSH/repos/klh-netbackup/browse/src/PolicyPattern.txt

Get-Help ConvertFrom-String -Parameter UpdateTemplate

#endregion
