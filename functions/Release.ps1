function Release {
    Param(
        [scriptblock]$ScriptBlock,
        [switch]$AndPrerelease,
        [string]$BuildTarget = $settings.BuildTarget
    )

    if(($PSBoundParameters.ContainsKey("AndPrerelease") -and $BuildTarget -in "Release", "Prerelease") -or $BuildTarget -eq "Release") {
        & $ScriptBlock
    }
}