#Requires -Version 3
function Get-Numbers {
    <#
        .Synopsis
            Generates lots of numbers, depending on the common paging parameters
        .Parameter Skip
            Controls how many things will be skipped before starting output. Defaults to 0.
        .Parameter First
            Indicates how many items to return. Defaults to 100.
        .Parameter IncludeTotalCount
            Causes an extra output of the total count at the beginning.
            Note this is actually a uInt64, but with a custom string representation.
    #>
    [CmdletBinding(SupportsPaging)]
    param()

    $FirstNumber = [Math]::Min($PSCmdlet.PagingParameters.Skip, 100)
    $LastNumber = [Math]::Min($PSCmdlet.PagingParameters.First +
      $FirstNumber - 1, 100)

    if ($PSCmdlet.PagingParameters.IncludeTotalCount) {
        $TotalCountAccuracy = 1.0
        $TotalCount = $PSCmdlet.PagingParameters.NewTotalCount(101, $TotalCountAccuracy)
        Write-Output $TotalCount
    }
    $FirstNumber .. $LastNumber | Write-Output
}

Get-Numbers -First 3
Get-Numbers -Skip 3 -First 4
$TotalCount, $numbers = Get-Numbers -First 5 -IncludeTotalCount
Get-Help Get-Numbers -Parameter IncludeTotalCount
