function Prerelease {
    Param(
        [scriptblock]$ScriptBlock,
        [string]$BuildTarget = $settings.BuildTarget
    )

    if($BuildTarget -eq "Prerelease") {
        & $ScriptBlock
    }
}