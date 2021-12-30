#Requires -Version 2.0

$Macro = '{#CLUSTER.DISK}'
$discoveryData = @()
$DiscoveryNamePart = $Macro.Replace('}', '') + '.'

$property = @('identity', 'path')

$data = @(
    @{
        FileSystem  = 'NTFS'
        VolumeLabel = 'quorum'
        Path        = 'kolmkümmend kolm'
        Used        = 48234496
        Identity    = 'Cluster Group.Cluster Disk 3_Path_Q:'
        Total       = 1069547520
        Free        = 1021313024
    }
    @{
        FileSystem  = 'NTFS'
        VolumeLabel = 'dts'
        Path        = 'sada kakskymmend'
        Used        = 83886080
        Identity    = 'SQL Network Name (sqlclu) Group.Cluster Disk 4_Path_Y:'
        Total       = 10733223936
        Free        = 10649337856
    }
)

$data | ForEach-Object {
    $DiscoveryItem = @{}
    if ($Property) {
        $object = $_
        foreach ($p in $Property) {
            if ($null -ne $Object."$p") {
                $Macro = ($DiscoveryNamePart + "$p}").ToUpper()
                $DiscoveryItem.Add($Macro, $Object."$p")
            }
        }
        $DiscoveryData += @($DiscoveryItem)
    } else {
        $DiscoveryItem.Add($Macro, $_.Identity)
        $DiscoveryData += @($DiscoveryItem)
    }
}

$discoveryData = @(
    @{
        "{#CLUSTER.DISK.PATH}" = "nimi"
        "{#CLUSTER.DISK.IDENTITY}" = 1
        "{#CLUSTER.DISK.REAL}" = $true
    }
    @{
        namm = "teine"
        val  = 2
        unreal = $false
    }
)

$StringData = '{"data":[' + "`n"
$count = $DiscoveryData.Count
foreach ($element in $DiscoveryData) {
    $keyCollection = $element.Keys
    $keycount = @($keyCollection).count
    $StringData += "`t" + '{' + "`n"
    foreach ($key in $keyCollection) {
        $StringData += "`t`t" + '"' + $key +'":' + "`t"
        $value = $element."$key"
        switch ($value.GetType().Name) {
            String {
                $StringData += ('"{0}"' -f $value)
            }
            Default {
                $StringData += $value.ToString()
            }
        }
        if ($keycount -gt 1) {
            $StringData += ',' + "`n"
        }
        $keycount--
    }
    $StringData += "`n`t" + '}'
    if ($count -gt 1) {
        $StringData += ','
    }
    $StringData += "`n"
    $count--
}
$StringData + "`n" + ']}'
