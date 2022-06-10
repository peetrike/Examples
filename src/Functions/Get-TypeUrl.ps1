function Get-TypeUrl {
    [CmdletBinding()]
    param (
            [parameter(
                ValueFromPipeline,
                ValueFromPipelineByPropertyName
            )]
            [Type]
        $Type,
            [switch]
        $Invoke
    )

    process {
        if ($Type.FullName -match '\[\]$') {
            $Type = $Type.BaseType
        }
        $FullName = $Type.FullName
        if ($FullName -match '^(System|Microsoft)') {
            $Url = 'https://docs.microsoft.com/dotnet/api/{0}' -f $FullName
            if ($Invoke.IsPresent) {
                Start-Process -FilePath $Url
            } else { $Url }
        } else {
            Write-Warning -Message ('The class is not part of Microsoft classes: {0}' -f $FullName)
        }
    }
}
