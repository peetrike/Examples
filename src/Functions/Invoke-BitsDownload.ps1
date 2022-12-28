#Requires -Version 2.0
#Requires -Modules BitsTransfer

function Invoke-BitsDownload {
    <#
        .DESCRIPTION
            Download files using BITS
        .EXAMPLE
            Invoke-BitsDownload 'https://server/path/file.zip'

            Downloads given URL to default destination (user TEMP directory)
        .EXAMPLE
            Invoke-BitsDownload -Url https://server/path/file.zip -Destination c:\downloads

            Downloads given URL to specified destination.
    #>

    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (
            [Parameter(
                Mandatory = $true,
                ValueFromPipelineByPropertyName = $true,
                Position = 0
            )]
            [uri]
        $Url,
            [ValidateScript( {
                Test-path -Path $_ -PathType Container
            })]
            [string]
        $Destination = $env:TEMP,
            [switch]
        $Force
    )

    process {
        $DownloadFileName = $Url.Segments[-1]
        $DownloadFullPath = Join-Path -Path $Destination -ChildPath $DownloadFileName

        if (Test-Path -Path $DownloadFullPath -PathType Leaf) {
            if ($Force.IsPresent) {
                Remove-Item -Path $DownloadFullPath -Force
            } else {
                Write-Warning -Message ('File {0} already exists' -f $DownloadfullPath)
                return
            }
        }

        $JobProps = @{
            Source        = $Url.AbsoluteUri
            Destination   = $Destination
            RetryInterval = 61
            DisplayName   = $DownloadFileName
            Asynchronous  = $true
        }
        $bitsjob = Start-BitsTransfer @JobProps
        Write-Verbose -Message ('Downloading {0}' -f $DownloadFileName)

        while ('Transferred', 'Error' -notcontains $bitsjob.JobState) {
            Write-Verbose -Message (
                'Downloading state: {0}; {1} Bytes' -f $bitsjob.JobState, $bitsjob.BytesTransferred
            )

            Start-Sleep -Seconds 3
            if ($bitsjob.JobState -eq "TransientError" -and $bitsjob.TransientErrorCount -lt 5) {
                $null = Resume-BitsTransfer -BitsJob $bitsjob -Asynchronous
            } elseif ($bitsjob.JobState -eq "TransientError") {
                Remove-BitsTransfer -BitsJob $bitsjob
                Write-Error -Message ('Transient error downloading from: {0}' -f $Url.OriginalString)
                return
            }
        }
        switch ($bitsjob.JobState) {
            'Transferred' {
                Complete-BitsTransfer -BitsJob $bitsjob
            }
            'Error' {
                Write-Error -Message 'An error occurred'
            }
        }
    }
}
