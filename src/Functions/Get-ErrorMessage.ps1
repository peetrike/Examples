function Get-ErrorMessage {
    <#
    .SYNOPSIS
        Retrieves the error message corresponding to a given Win32 error code.
    .DESCRIPTION
        This function uses the WSMan.Automation COM object to fetch the
        error message associated with a specified Win32 error code.
    #>
    param (
            [Parameter(Mandatory = $true)]
            [int]
            # The Win32 error code for which to retrieve the error message.
        $ErrorCode
    )

    $WsMan = New-Object -ComObject WSMan.Automation

    $ConvertedCode = $ErrorCode -band 0xFFFF
    $wsman.GetErrorMessage($ConvertedCode)
}
