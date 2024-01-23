#Requires -Version 7.2

function Get-AnsiEscape {
    <#
        .DESCRIPTION
        aliases instead of parameters?
        why not both?
        .EXAMPLE
        $sample = "$($PSStyle.Foreground.BrightGreen)Hello $($PSStyle.Background.Magenta)$($PSStyle.FormatHyperlink('world!','https://www.example.com'))$($PSStyle.Reset)"
        .LINK
        https://gist.github.com/trackd/c0d18512a56c0ba3c0b8e588d997f207
    #>
    [Alias('StripAnsi', 'EscapeAnsi', 'RegexAnsi', 'GetAnsi')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String] $InputObject,
        [Switch] $StripAnsi,
        [Switch] $EscapeAnsi,
        [Switch] $RegexAnsi,
        [Switch] $All
    )
    begin {
        Write-Verbose (
            'Command: {0} Alias: {1} Param: {2}' -f $MyInvocation.MyCommand.Name,
            $MyInvocation.InvocationName,
            ($PSBoundParameters.Keys -join ', ')
        )
        filter _EscapeAnsi {
            <# from Ninmonkey #>
            $_.EnumerateRunes() | ForEach-Object {
                if ($_.Value -le 0x1f) {
                    [Text.Rune]::new($_.Value + 0x2400)
                }
                else {
                    $_
                }
            } | Join-String
        }
        filter _StripAnsi {
            <# clean string, but gives link text instead of url #>
            return [Management.Automation.Host.PSHostUserInterface]::GetOutputString($_, $false)
        }
        filter _RegexAnsi {
            <# this should handle ANSI colors and OSC sequences, mostly useful for links, to get url and text #>
            $Regex = @{
                ansi      = '\x1b\[[0-?]*[ -/]*[@-~]'
                # OSCRegex = '\x1B]\d;'
                linkRegex = '\x1B]8;;'
                urlSplit  = '\x1b\\'
            }
            $_ -replace $Regex.ansi | ForEach-Object {
                if ($_ -match '\x1b') {
                    $_ -replace $Regex.linkRegex -split $regex.urlSplit | ForEach-Object {
                        if (-Not [String]::IsNullOrWhiteSpace($_)) {
                            # if anything is missed by the regex, just replace the escape char to make it visible
                            if ($_ -match '\x1b') {
                                $_ -replace '\x1B',([char]0x241b)
                            }
                            else {
                                $_
                            }
                        }
                    }
                } else {
                    $_
                }
            }
        }
    }
    process {
        # this is mostly just an experiment
        if (-Not $All) {
            switch ($PSBoundParameters.Keys) {
                # if a parameter is specified
                'StripAnsi' { return $InputObject | _StripAnsi }
                'EscapeAnsi' { return $InputObject | _EscapeAnsi }
                'RegexAnsi' { return $InputObject | _RegexAnsi }
            }
            switch ($MyInvocation.InvocationName) {
                # if an alias is used
                'StripAnsi' { return $InputObject | _StripAnsi }
                'EscapeAnsi' { return $InputObject | _EscapeAnsi }
                'RegexAnsi' { return $InputObject | _RegexAnsi }
            }
        }
        $ht = [ordered]@{}
        $ht.Original = $InputObject
        $ht.Escaped = $InputObject | _EscapeAnsi
        $ht.Clean = $InputObject | _StripAnsi
        # gate the regex to avoid unnecessary processing, check for the escape sequence needed for links
        if ($InputObject -match '\x1b]' -or $All) {
            if (($test = $InputObject | _RegexAnsi) -ne $ht.Clean) {
                $ht.OSC = $test
            }
        }
        [PSCustomObject]$ht
    }
}
