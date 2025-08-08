Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^\w:\\$' } |
    ForEach-Object {
        Get-ChildItem -Path $_.Root -Include *sqlite3.dll, *sqlite3.exe -Recurse -ErrorAction SilentlyContinue
    } |
    ForEach-Object {
        [PSCustomObject] @{
            ComputerName = get-hostname -Fqdn
            FileName     = $_.Name
            FilePath     = $_.FullName
            Version      = $_.VersionInfo.FileVersion
            Description  = $_.VersionInfo.FileDescription
            Product      = $_.VersionInfo.ProductName
        }
    }
