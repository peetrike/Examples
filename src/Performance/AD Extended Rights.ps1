#Requires -Version 2.0
# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'result')]
param (
    $Min = 10,
    $Max = 1000
)

$rootDse = Get-ADRootDSE
$schemaContext = $rootDse.SchemaNamingContext
$configContext = $rootDse.ConfigurationNamingContext

Write-Verbose -Message 'Retrieving Schema GUIDs from Schema Partition'
$schemaProperty = 'schemaIDGUID'
$schemaSplat = @{
    SearchBase = $schemaContext
    Properties = $schemaProperty
}
$computerGuid = [guid](Get-ADObject -Filter { Name -eq 'Computer' } @schemaSplat).$schemaProperty

$AllSplat = @{
    SearchBase = 'CN=Extended-Rights,' + $configContext
    LDAPFilter = '((rightsGuid=*))'
    Properties = 'DisplayName', 'rightsGuid'
}
$ComputerSplat = @{
    SearchBase = 'CN=Extended-Rights,' + $configContext
    LDAPFilter = "((appliesTo=$computerGuid))"
    Properties = 'DisplayName', 'rightsGuid'
}
$ADFilterSplat = @{
    SearchBase = 'CN=Extended-Rights,' + $configContext
    Filter     = { appliesTo -eq $computerGuid }
    Properties = 'DisplayName', 'rightsGuid'
}

$Technique = @{
    'All rights'       = {
        $extendedRightsMap = @{}
        Get-ADObject @AllSplat |
            ForEach-Object { $extendedRightsMap[$_.DisplayName] = [guid]$_.rightsGuid }
    }
    'Computer rights'  = {
        $extendedRightsMap = @{}
        Get-ADObject @ComputerSplat |
            ForEach-Object { $extendedRightsMap[$_.DisplayName] = [guid]$_.rightsGuid }
    }
    'AD filter rights' = {
        $extendedRightsMap = @{}
        Get-ADObject @ADFilterSplat |
            ForEach-Object { $extendedRightsMap[$_.DisplayName] = [guid]$_.rightsGuid }
    }
}

if ($PSVersionTable.PSVersion.Major -eq 2) {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName $iterations
}
