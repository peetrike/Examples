#Requires -Modules PSReadLine

[CmdletBinding()]
Param (
        [int]
        # top number of results to return
    $Top = 5
)

Function Get-MostUsedCommand {
    <#
        .Synopsis
            Gets most used PowerShell commands
        .DESCRIPTION
            Uses the parser and command history to construct a list of the
            most used commands and returns a sorted list. The -TOP parameter
            tells how many results to return.
        .EXAMPLE
            PS [C:\foo> ]> Get-MostUsedCommands

            Count Name
            ----- ----
             1442 git
              832 cd
              578 ls
              353 f
              243 cc
        .INPUTS
            None
        .OUTPUTS
            Collection of most used commands
        .NOTES
            Based on a tweet by @stevenjudd
            Taken from: https://tfl09.blogspot.com/2019/06/what-powershell-commands-do-you-use.html
            Works in Windows PowerShell 5.1, PowerShell 7 Preview 1.
    #>

    [CmdletBinding()]
    Param (
            [int]
            # top number of results to return
        $Top = 5
    )

    $ERR = $null
    [System.Management.Automation.PSParser]::Tokenize(
        (Get-Content (Get-PSReadLineOption).HistorySavePath),
        [ref]$ERR
    ) |
        Where-Object { $_.Type -eq 'command' } |
        Select-Object -Property Content |
        Group-Object -Property Content -NoElement |
        Sort-Object -Property Count, Name -Descending |
        Select-Object -First $Top
}

Get-MostUsedCommand @PSBoundParameters
