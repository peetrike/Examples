function Get-KerbEncryptionUsage {
    [CmdletBinding()]
    param (
            [ValidateSet('RC4', 'DES', 'AES-SHA1', 'AES-SHA2', 'All')]
            [string]
        $Encryption = 'All',
            [DateTime]
        $Since = [datetime]::Now.AddDays(-30),
            [ValidateSet('Ticket', 'SessionKey', 'Either', 'Both')]
            [string]
        $EncryptionUsage = 'Either',
            [int]
        $MaxEvents = 1
    )

    enum RequestType {
        TicketGrantingTicket
        ServiceTicket
    }
    enum EncryptionType {
        DesCrc = 0x1
        DesMd5 = 0x3
        Aes128 = 0x11
        Aes256 = 0x12
        Aes128Sha256 = 0x13
        Aes256Sha384 = 0x14
        Rc4 = 0x17
        Rc4Exp = 0x18
        Unknown = -1
    }

    $ResultFilter = @{
        RC4        = [EncryptionType]::Rc4, [EncryptionType]::Rc4Exp
        DES        = [EncryptionType]::DesCrc, [EncryptionType]::DesMd5
        'AES-SHA1' = [EncryptionType]::Aes128, [EncryptionType]::Aes256
        'AES-SHA2' = [EncryptionType]::Aes128Sha256, [EncryptionType]::Aes256Sha384
        # Unknown    = [EncryptionType]::Unknown
    }
    $ResultFilter['All'] = foreach ($k in $ResultFilter.Keys) { $ResultFilter.$k }

    $EventFilter = @{
        LogName   = 'Security'
        Id        = 4768, 4769
        StartTime = $Since
    }

    Get-WinEvent -FilterHashtable $EventFilter | ForEach-Object {
        $EventXml = [xml] $_.ToXml()
        $ticketEncryption = [EncryptionType] [int] $EventXml.SelectSingleNode(
            '//*[@Name = "TicketEncryptionType"]'
        ).InnerText
        Write-Verbose -Message ('Processing event: {0}, TicketEncryption: {1}' -f $_.Id, $ticketEncryption)
        [PSCustomObject] @{
            TimeCreated       = $_.TimeCreated
            EventId           = $_.Id
            RequestType       = [RequestType] [int] ($_.id -eq 4769)
            Target            = $EventXml.SelectSingleNode('//*[@Name = "ServiceName"]').InnerText
            IPAddress         = $EventXml.SelectSingleNode('//*[@Name = "IpAddress"]').InnerText
            TicketEncryption  = $ticketEncryption
            SessionEncryption = [EncryptionType] [int] $EventXml.SelectSingleNode(
                '//*[@Name = "SessionKeyEncryptionType"]'
            ).InnerText
        }
    } | Where-Object {
        $currentEvent = $_
        switch ($EncryptionUsage) {
            'Ticket' { $ResultFilter[$Encryption] -contains $currentEvent.TicketEncryption }
            'SessionKey' { $ResultFilter[$Encryption] -contains $currentEvent.SessionEncryption }
            'Either' {
                $ResultFilter[$Encryption] -contains $currentEvent.TicketEncryption -or
                $ResultFilter[$Encryption] -contains $currentEvent.SessionEncryption
            }
            'Both' {
                $ResultFilter[$Encryption] -contains $currentEvent.TicketEncryption -and
                $ResultFilter[$Encryption] -contains $currentEvent.SessionEncryption
            }
        }
    } | Select-Object -First $MaxEvents
}
