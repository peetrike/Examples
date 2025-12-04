function Get-SmtpPublicIP {
    [CmdletBinding()]
    param (
            [Parameter(
                Mandatory = $true,
                HelpMessage = 'Specify the SMTP server to connect to.'
            )]
            [Alias('SmtpServer', 'ComputerName', 'CN')]
            [string]
        $Server
    )

    $smtp = New-Object -TypeName Net.Sockets.TcpClient -ArgumentList $Server, 25
    $stream = $smtp.GetStream()

    $reader = New-Object -TypeName IO.StreamReader -ArgumentList $stream
    $writer = New-Object -TypeName IO.StreamWriter -ArgumentList $stream
    $writer.AutoFlush = $true

    # Read banner
    <# $null = #> $reader.ReadLine()

    # Send EHLO command
    $writer.WriteLine('EHLO yourhostname')
    $reader.ReadLine()

    # Close when done
    $smtp.Close()
}
