# the problem below occurs only when assigning value (in scriptblock) to variable and not using *-Variable commands
# in the same scriptblock.  Then, using Remove-Item fails

#region problem
& {
    $myVar=11
    Remove-Item -Path Variable:\myVar
}

& {
    & (Get-Command -Name new-variable) test
    $test2=12
    Remove-Item variable:test2
}
#endregion

#region No Problem
& {
    New-Variable -Name myVar -Value 11
    Remove-Item -Path Variable:\myVar
}

& {
    $test = 11
    New-Variable -Name myVar -Value 11
    Remove-Item -Path Variable:\test
}

& {
    if (Test-Path -path variable:test ) {
        Remove-Variable -Name test
    }
    $test2 = 11
    Remove-Item -Path Variable:\test2
}

#endregion
