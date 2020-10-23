<#
    .SYNOPSIS
        Shows arguments with script validation attribute.
    .DESCRIPTION
        This script is using named arguments with ValidateScript attribute.

        The validation scriptblock must return boolean value.  The assigned value in that scriptblock is mapped to
        $_ variable.
    .EXAMPLE
        & './08 ValidateScript.ps1' -File newfile.txt

        This example will work as parameter Path has default value (current working directory).
    .EXAMPLE
        & './08 ValidateScript.ps1' -Path nonexisting

        This example will fail if specified path ('nonexisting') doesn't exist.
    .EXAMPLE
        & './08 ValidateScript.ps1' -Path2 nonexisting

        This example will also fail if specified path ('nonexisting') doesn't exist.
        But parameter Path2 will throw its own error message, which is more readable for regular user.
    .EXAMPLE
        New-Item -Name folder -ItemType File
        & './08 ValidateScript.ps1' -Path2 folder
        & './08 ValidateScript.ps1' -Path folder

        This example will fail because specified path ('folder') is file, not folder.
    .LINK
        https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
#>

[CmdletBinding()]
param (
        [System.IO.FileInfo]
    $File,
        [ValidateScript({ Test-Path $_ -PathType Container })]
    $Path = $PWD,
        [ValidateScript({
            if (Test-Path $_ -PathType Container) {
                $true
            } else {
                throw 'The specified folder not found'
            }
        })]
        [System.IO.DirectoryInfo]
    $Path2
)

Write-Verbose -Message ('Path: {0}' -f $Path)
if ($Path2) {
    Write-Verbose -Message ('FullName of Path2: {0}' -f $Path2.FullName)
}

if ($File) {
    $FilePath = join-path -Path $Path -ChildPath $File

    if (Test-Path $FilePath -PathType Leaf) {
        'file exists'
    } else {
        New-Item -Path $Path -Name $File -ItemType File
    }
}
