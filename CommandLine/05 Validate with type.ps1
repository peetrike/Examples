<#
    .SYNOPSIS
        Shows how data types can be used for validation.
    .DESCRIPTION
        This script is .NET types to perform validation.
        PowerShell works on top of .NET and all types available in .NET are also available in PowerShell.
        The only possible problem is, that .NET types depend on available .NET version and installed software.
    .NOTES
        There are parameters -Email and -Email2.  The second is using Regular Expression pattern validation and it
        seems that the result is similar to the .NET type.
    .EXAMPLE
        & './05 Validate with type.ps1' -Email "This is me <me@somewhere.com>"

        This command line will be accepted as included value can be converted to e-mail address.
    .EXAMPLE
        & './05 Validate with type.ps1' -Email2 me@here.some_thing

        This command line will be accepted as included value will pass validation regular expression.
    .EXAMPLE
        & './05 Validate with type.ps1' -Email me@

        This example will fail because included value can't be converted to e-mail address .NET type.
    .EXAMPLE
        & './05 Validate with type.ps1' -IpAddress 1.2.3.4

        This example will work as included value can be converted to valid IP address.
    .EXAMPLE
        & './05 Validate with type.ps1' -IpAddress fd03::2

        This example will also work as included value can be converted to valid IP address.
    .EXAMPLE
        & './05 Validate with type.ps1' -IpAddress 26493874

        This example will also work as included value can be interpreted as IP address.
    .EXAMPLE
        & './05 Validate with type.ps1' -IpAddress 264.2.9.10

        This example will fail as included value is not valid IP address.
    .Link
        https://docs.microsoft.com/dotnet/api/system.net.mail.mailaddress
    .Link
        https://docs.microsoft.com/dotnet/api/system.net.ipaddress
#>

param (
        [mailaddress]
    $Email,
        [ValidatePattern('.+@.+')]
    $Email2,
        [ipaddress]
    $IpAddress
)

if ($IpAddress) {
    'IP address: {0}' -f $IpAddress
}
