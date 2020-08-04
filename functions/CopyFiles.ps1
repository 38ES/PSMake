function CopyFiles {
    param(
        [scriptblock]$ScriptBlock,
        [string]$To = $settings.OutputModulePath
    )

    & $ScriptBlock | % {
        if($_ -is [string]) {
            Get-ChildItem $_
        } elseif($_ -is [System.IO.FileInfo]) {
            $_
        } else {
            throw "Unexpected item to copy - '$_'"
        }
    } | % {
        Copy-Item $_.FullName $To
    }
}