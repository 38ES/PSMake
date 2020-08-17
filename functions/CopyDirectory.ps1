using namespace System.IO;

function CopyDirectory {
    Param(
        [ScriptBlock]$ScriptBlock,
        [string]$To = $settings.OutputModulePath
    )

    if($To -ne $settings.OutputModulePath) { 
        $To = (Resolve-Path (Join-Path $settings.OutputModulePath $To)).Path
    }

    & $ScriptBlock | ForEach-Object {
        if($_ -is [string]) {
            [DirectoryInfo]::new($_)
        } elseif($_ -is [DirectoryInfo]) {
            $_
        } else {
            throw "Unexpected directory to copy - '$_'"
        }
    } | ForEach-Object {
        Copy-Item $_.FullName $To -Recurse
    }
}