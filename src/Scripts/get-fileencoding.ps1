##############################################################################
##
## Get-FileEncoding
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##############################################################################

<#
    .SYNOPSIS
        Gets the encoding of a file

    .EXAMPLE
        PS> Get-FileEncoding.ps1 .\UnicodeScript.ps1

#>

[CmdletBinding()]
[OutputType([System.Text.Encoding])]
param (
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [IO.FileInfo]
        # Path to the file to be checked
    $Path
)

begin {
    ## The hashtable used to store our mapping of encoding bytes to their
    ## name. For example, "255-254 = Unicode"
    $encodings = @{}

    ## Find all of the encodings understood by the .NET Framework. For each,
    ## determine the bytes at the start of the file (the preamble) that the .NET
    ## Framework uses to identify that encoding.
    foreach ($encoding in [System.Text.Encoding]::GetEncodings()) {
        if ($preamble = $encoding.GetEncoding().GetPreamble()) {
            $encodingBytes = $preamble -join '-'
            $encodings[$encodingBytes] = $encoding.GetEncoding()
        }
    }

    ## Find out the lengths of all of the preambles.
    $encodingLengths = $encodings.Keys | Where-Object { $_ } |
        Foreach-Object { ($_ -split "-").Count }
}

process {
    ## First, check if the file is binary. That is, if the first
    ## 5 lines contain any non-printable characters.
    $nonPrintable = [char[]] (0..8 + 10..31 + 127 + 129 + 141 + 143 + 144 + 157)
    $lines = Get-Content $Path -ErrorAction Ignore -TotalCount 5
    $result = @($lines | Where-Object { $_.IndexOfAny($nonPrintable) -ge 0 })
    if ($result.Count -gt 0) {
        "Binary"
        return
    }

    ## Assume default encoding default
    $result = [System.Text.Encoding]::Default

    ## Next, check if it matches a well-known encoding.
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        [byte[]]$bytes = Get-Content -Encoding byte -TotalCount 4 -Path $Path
    } else {
        [byte[]]$bytes = Get-Content -AsByteStream -TotalCount 4 -Path $Path
    }

    Write-Verbose -Message ('Bytes: {0} {1} {2} {3}' -f $bytes[0], $bytes[1], $bytes[2], $bytes[3])

    ## Go through each of the possible preamble lengths, read that many
    ## bytes from the file, and then see if it matches one of the encodings
    ## we know about.
    foreach ($encodingLength in $encodingLengths | Sort-Object -Descending) {
        $comparebytes = $bytes | Select-Object -First $encodingLength
        $encoding = $encodings[$comparebytes -join '-']

        ## If we found an encoding that had the same preamble bytes,
        ## save that output and break.
        if ($encoding) {
            $result = $encoding
            break
        }
    }

    ## Finally, output the encoding.
    $result
}
