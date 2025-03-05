
# get current DC for computer:
[DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain().FindDomainController()

# get current DC for user:
[DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().FindDomainController()

# Get Global Catalog Server:
[DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().FindGlobalCatalog()

# force rediscovery of DC:
$Locator = [DirectoryServices.ActiveDirectory.LocatorOptions]::ForceRediscovery
[DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().FindDomainController($Locator)
