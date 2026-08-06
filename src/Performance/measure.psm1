function Measure-ScriptBlock {
    param (

            [Parameter(Mandatory = $true)]
            [Collections.IDictionary]
        $Technique,
            [Alias('RepeatCount')]
            [int]
        $Iterations = 10000,
            [string]
        $GroupName
    )

    $ScriptName = Get-ScriptName

    $ThroughPut = @{
        Name       = 'ThroughPut'
        Expression = { $_.ThroughPut }
        Format     = '{0:N2}/s'
    }
    $KeyCount = $Technique.Keys.Count
    $TechniqueCounter = 0

    $Technique.Keys | ForEach-Object {
        $TechniqueCounter++
        $percentComplete = 100 * $TechniqueCounter / $KeyCount
        $method = $_

        $progressSplat = @{
            Activity        = "Timing $method"
            Status          = "Over $Iterations repetitions"
            PercentComplete = $percentComplete
        }
        Write-Progress @progressSplat

        $TimeSpent = 1..$Iterations |
            Measure-Command $Technique.$method

        New-Object -TypeName psobject -Property @{
            Method     = $method
            Time       = $TimeSpent
            ThroughPut = $Iterations / $TimeSpent.TotalSeconds
            ScriptName = $ScriptName
            Benchmark  = @($ScriptName, $GroupName) -join ' - '
        }
    } |
        Sort-Object -Property Time |
        Format-Table -AutoSize -Property Method, Time, $ThroughPut -GroupBy Benchmark
}

function Get-ScriptName {
    [CmdletBinding()]
    param ()

    $namePattern = '(\.benchmark)?\.ps1$'
    $StackItem = Get-PSCallStack | Where-Object { $_.ScriptName -match $namePattern } | Select-Object -First 1
    (Split-Path -Path $StackItem.ScriptName -Leaf) -replace $namePattern
}

Set-Alias -Name Measure-Benchmark -Value Measure-ScriptBlock
Export-ModuleMember -Function Measure-ScriptBlock -Alias Measure-Benchmark
