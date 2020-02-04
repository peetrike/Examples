#Requires -Version 5.1

[CmdletBinding(
    SupportsShouldProcess
)]
param (
        [Parameter(
            Mandatory
        )]
        [ValidateScript({
            Test-Path -Path $_ -PathType Container
        })]
        [string[]]
    $Path,
        [Parameter(
            Mandatory
        )]
        [ValidateScript({
            Test-Path -Path $_ -PathType Container
        })]
        [string]
    $TargetPath,
        [switch]
    $Unique
)

begin {
    $oWord = New-Object -ComObject 'Word.Application'
}
<# $FileProps = @(
    'Filename'
    'File extension'
    'Title'
    'Authors'
    'Path'
    'Content created'
    'Date last saved'
    'Last printed'
) #>
process {
    Get-ChildItem -Path $Path -Filter '*.docx' -File -Recurse |
        ForEach-Object {
            $wordXml = $null
            $file = $_
            Write-Progress -Activity 'Processing restored files' -Status ('Checking {0}' -f $file.Fullname)

            try {
                Write-Verbose -Message ('Opening Document {0}' -f $file.FullName)
                $WordDocument = $oWord.Documents.Open($file.FullName)
                Write-Verbose 'Extracting XML properties'
                $wordXml = [xml] ($WordDocument | Select-Object -ExpandProperty WordOpenXML)
                $WordDocument.Close()
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($WordDocument)

            } catch {
                Write-Error -ErrorRecord $_ -ErrorAction Continue
            }

            if ($wordXml) {
                $WordCoreProperties = ($wordXml.package.part | Where-Object name -like '/docProps/core.xml').xmldata.coreProperties

                $targetfolderName = ''
                if ($WordCoreProperties.lastModifiedBy) {
                    $targetfolderName = $WordCoreProperties.lastModifiedBy.split([io.path]::GetInvalidPathChars()) -join '_'
                } elseif ($WordCoreProperties.creator) {
                    $targetfolderName = $WordCoreProperties.creator.split([io.path]::GetInvalidPathChars()) -join '_'
                }

                if ($targetfolderName) {
                    $TargetFilePath = Join-Path -Path $TargetPath -ChildPath $targetfolderName
                } else {
                    $TargetFilePath = $TargetPath
                }

                if (-not (Test-Path -Path $TargetFilePath -PathType Container)) {
                    $null = New-Item -Path $TargetFilePath -ItemType Directory #-Force
                }

                $TargetFileName = $file.Name
                if ($WordCoreProperties.Title) {
                    $TargetFileName = $WordCoreProperties.title.Trim(' ').split([io.path]::GetInvalidFileNameChars()) -join '_'
                    $TargetFileName += ' - ' + $file.Name
                }
                $targetFile = Join-Path -Path $TargetFilePath -ChildPath $TargetFileName
                if (-not $Unique) {
                    $n = 0
                    while (Test-Path -Path $targetFile -PathType Leaf) {
                        $n++
                        $NewFileName = $TargetFileName.trimend($file.Extension) + ' (' + $n + ')' + $file.Extension
                        $targetFile = Join-Path -Path $TargetFilePath -ChildPath $NewFileName
                    }
                    # Write-Verbose -Message ('Creating {0}' -f $targetFile)
                    $NewFile = Copy-Item -Path $file.FullName -Destination $targetFile -PassThru
                } elseif (-not (Test-Path -Path $targetFile -PathType Leaf)) {
                    $NewFile = Copy-Item -Path $file.FullName -Destination $targetFile -PassThru
                }
                if ($NewFile) {
                    $created = [datetime]$WordCoreProperties.created.'#text'
                    $modified = [datetime]$WordCoreProperties.modified.'#text'
                    if ($modified) {
                        Write-Verbose -Message ('Modified: {0}' -f $modified)
                        if ($NewFile.LastWriteTime -ne $modified) {
                            $NewFile.LastWriteTime = $modified
                        } else {
                            Write-Verbose -Message ('LastSaved date already correct: {0}' -f $NewFile.Name)
                        }
                    } else {
                        Write-Verbose 'no modified date in file properties'
                    }
                    if ($created) {
                        Write-Verbose -Message ('Created: {0}' -f $created)
                        if ($NewFile.CreationTime -ne $Created) {
                            $NewFile.CreationTime = $Created
                        } else {
                            Write-Verbose -Message ('Created date already correct: {0}' -f $NewFile.Name)
                        }
                    } else {
                        Write-Verbose 'No created date in file properties'
                    }
                    $NewFile
                }
            }
        }
}

end {
    Remove-Variable -Name WordDocument
    $oWord.Quit()
    Remove-Variable -Name oWord
}
