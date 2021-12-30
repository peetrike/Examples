#Requires -Modules RemoteDesktop

$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\CentralPublishedResources\PublishedFarms\'

$collection = Get-RDSessionCollection

foreach ($coll in $collection) {
    $ItemPath = Join-Path -path $RegPath -ChildPath ($coll.CollectionAlias, 'DeploymentSettings' -join '\')
    $setting = (Get-ItemProperty -Path $ItemPath).DeploymentRDPSettings
    $coll.CollectionAlias
    $setting
}
