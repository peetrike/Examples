#Requires -Version 3.0

$charExtentionsType = [psobject].Assembly.GetType('System.Management.Automation.Language.CharExtensions')
$isTypeSuffixMethod = $charExtentionsType.GetMethod('IsTypeSuffix', [System.Reflection.BindingFlags]'Static,NonPublic')
[char[]]@(
    97..122 | Where-Object { $IsTypeSuffixMethod.Invoke($null, @([char]$_)) }
)
