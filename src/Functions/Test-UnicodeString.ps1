﻿function Test-UnicodeString {
    <#
        .SYNOPSIS
            Test if a string contains non-ASCII characters
        .DESCRIPTION
            Test if a string contains non-ASCII characters, returns true if it does, false if it does not.
            This function can be used to provide the correct character encoding for the different web cmdlets.
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param (
            [string]
        $String
    )

    [regex]::IsMatch($String, '[^\u0020-\u007F]')
}
