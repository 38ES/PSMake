function SetPrereleaseTag {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Tag', Justification = 'Used in a ForEach-Object scriptblock')]
    Param(
        [scriptblock]$ScriptBlock,
        [string]$Tag = "rc$((Get-Date).ToString("yyyyMMddHHmm"))"
    )

    & $ScriptBlock | ForEach-Object {
        $path = Join-Path $settings.OutputModulePath $_

        if (-not (Test-Path $path -PathType Leaf)) {
            throw "Path '$_' is not file"
        }

       Update-Metadata $path -PropertyName "PrivateData.PSData.Prerelease" -Value $Tag

    }
}