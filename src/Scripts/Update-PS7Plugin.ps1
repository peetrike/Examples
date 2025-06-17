Get-PSSessionConfiguration PowerShell.7.* | Unregister-PSSessionConfiguration

$PluginSplat = @{
    Path = $PSHOME.Replace($Env:ProgramFiles, '%ProgramFiles%')
    ChildPath = 'pwrshplugin.dll'
}
$WSManPluginPath = Join-Path @PluginSplat

<# $WSManSelection = @{
    ResourceURI = 'winrm/config/plugin'
    SelectorSet = @{ Name = 'PowerShell.7' }
}
Set-WSManInstance @WSManSelection -ValueSet = @{ Filename = $WSManPluginPath } #>

$BasePath = 'WSMan:\localhost\Plugin\PowerShell.7'
Set-Item -Path "$BasePath\FileName" -Value $WSManPluginPath
Set-Item -Path "$BasePath\InitializationParameters\PSVersion" -Value 7
