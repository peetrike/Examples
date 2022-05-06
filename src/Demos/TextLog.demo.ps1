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
    .LINK
        https://peterwawa.wordpress.com/tag/log/
#>

#region Safety to prevent the entire script from being run instead of a selection
throw "You're not supposed to run the entire script"
#endregion

#region Possible ways to process text files

Get-Command -Noun content

Get-Command -Verb import -Module Microsoft.PowerShell.Utility
Get-Command -Verb convertfrom -Module Microsoft.PowerShell.Utility

#endregion

#region Using XML log files

$XmlContent = [xml] (Get-Content mylog.xml)
    # use XPath filtering to get relevant data
$xmlcontent.SelectNodes('//data')

#endregion

#region Using JSON log files

$JsonContent = Get-Content mylog.json | ConvertFrom-Json

$JsonContent | Where-Object Name -like 'myData'

#endregion

#region (ab)Using CSV log files

$mydata = Import-Csv mylog.txt

get-help Import-Csv

$header = 'first, second, third'
$mydata = Import-Csv mylog.txt -Header $header
    #alternate way
$mydata = @(
    $header
    Get-Content mylog.txt
) | ConvertFrom-Csv

# Estonian regional settings
$mydata = Import-Csv mylog.txt -UseCulture
$mydata = Import-Csv mylog.txt -Delimiter ';'

Get-Help import-csv -Parameter Encoding
    # this is for PowerShell 7
$mydata = Import-Csv mylog.txt -UseCulture -Encoding utf8BOM

get-help import-csv -Parameter delimiter
import-csv mylog.txt -Delimiter "`t"

#endregion

#region Searching from text files

Get-help Select-String

Select-String -Pattern '^#' -Path *.txt

    #multiline log files
get-help Select-String -Parameter Context

$found = Select-String -Pattern '^#' -Path *.txt -Context 0, 2
$found | Get-Member

#endregion

#region ConvertFrom-String

Get-Help ConvertFrom-String
get-help ConvertFrom-String -Examples

Get-Help ConvertFrom-String -Parameter Delimiter

$myData = Get-Content myfile.log | ConvertFrom-String -Delimiter '\s+'

"tere tulemast" | ConvertFrom-String
"tere `t tulemast" | ConvertFrom-String
"tere `t tulemast" | ConvertFrom-String -PropertyNames 'yks', 'kaks'

(get-help ConvertFrom-String).examples.example[4]
#endregion
