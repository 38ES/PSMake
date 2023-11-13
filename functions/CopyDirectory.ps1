using namespace System.IO;

function CopyDirectory {
    Param(
        [ScriptBlock]$ScriptBlock,
        [string]$To = $settings.OutputModulePath
    )

    if($To -ne $settings.OutputModulePath -and -not (Split-Path $To -IsAbsolute)) {
        $To = Join-Path $settings.OutputModulePath $To
    }

    & $ScriptBlock | ForEach-Object {
        if($_ -is [string]) {
            if(Split-Path $_ -IsAbsolute) {
                $_
            } else {
                (Join-Path $PWD.Path $_)
            }
        } elseif($_ -is [DirectoryInfo]) {
            $_.FullName
        } else {
            throw "Unexpected directory to copy - '$_'"
        }
    } | ForEach-Object {
        Copy-Item $_ $To -Recurse
    }
}