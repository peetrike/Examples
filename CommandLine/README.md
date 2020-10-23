# Command line samples

Here are different scripts that show what and how can you do with command line
parameters in Powershell.

Every script in this folder has extensive comment-based help, that try to
explain what and how it works.

You can open scripts or use built-in discovery methods to see details about
scripts.

```powershell
Get-Help './01 Simple Arguments.ps1' -Examples
(Get-Help './02 Named Parameters.ps1').examples.example[1]
Invoke-Expression (Get-Help './02 Named Parameters.ps1').examples.example[0].code

(Get-Help './04 Named with validation.ps1').syntax
Get-Command './13 Parameter sets.ps1' -Syntax

(Get-Help './07 ValidateString.ps1').Synopsis
Get-Help './02 Named Parameters.ps1' -Detailed

Get-Help './03 Named with type.ps1' -Parameter One
(Get-Command './05 Validate with type.ps1').Parameters.IpAddress
(Get-Command './06 ValidateCount.ps1').ResolveParameter('Value')

Start-Process (Get-Help './04 Named with validation.ps1').relatedlinks.navigationlink.uri
```

## Concepts

Everything used in scripts is also applicable to functions and scriptblocks.
For example:

```powershell
function test {
    param ($One)

    'The value of $one:'
    $One
}

test -One 1,2,3
test 1 2
```

or

```powershell
$ScriptBlock = {
    param ($One)

    'The value of $one:'
    $One
}

& $ScriptBlock -One 1,2,3
& $ScriptBlock 1 2
```

## About naming stuff

PowerShell language itself is not case sensitive.  That means that it doesn't
matter whether you write language elements in uppercase or lowercase.  The same
concept applies to variable names and function names.

To make the code more readable (variables, functions, scripts), you could
follow the recommendations from next sources:

- [The PowerShell Best Practices and Style Guide](https://poshcode.gitbooks.io/powershell-practice-and-style/)
- [.NET Framework Design Guidelines](https://docs.microsoft.com/en-us/dotnet/standard/design-guidelines/naming-guidelines)
