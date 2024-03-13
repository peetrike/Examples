function Expand-ZipFile {
    [CmdletBinding()]
    param (
            [Parameter(
                Mandatory = $true
            )]
            [ValidateScript({
                if (Test-Path -Path $_ -PathType Leaf) { $true } else {
                    throw [Management.Automation.ItemNotFoundException] ('Path not found: {0}' -f $_)
                }
            })]
        $Path,
            [string]
        $DestinationPath,
            [switch]
        $Force
    )

    if (-not $DestinationPath) {
        $DestinationPath = $Path -replace '.zip', ''
    }

    Write-Verbose -Message ('Extract target: {0}' -f $DestinationPath)
    if (Test-Path -Path $DestinationPath -PathType Container) {
        if ($Force) {
            Write-Verbose -Message "Removing folder $DestinationPath"
            Remove-Item -Path $DestinationPath -Force -Recurse
        } else {
            throw "Folder $DestinationPath already exists"
        }
    }

    if ($PSVersionTable.PSVersion.Major -ge 5) {
        Expand-Archive -Path $Path -DestinationPath $DestinationPath -Force:$Force
    } else {
        Write-Verbose -Message 'Extracting using Windows Shell'
        $shell = New-Object -ComObject Shell.Application
        $ArchiveItem = Get-Item -Path $Path
        if (Test-Path -Path $DestinationPath -PathType Container) {
            $DestinationItem = Get-Item -Path $DestinationPath
        } else {
            $DestinationItem = New-Item -Path $DestinationPath -ItemType Directory
        }
        $ShellArchive = $shell.Namespace($ArchiveItem.FullName)
        foreach ($item in $ShellArchive.Items()) {
            $shell.Namespace($DestinationItem.FullName).CopyHere($item)
        }
    }
}
