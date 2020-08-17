using namespace System.IO

function CreateDirectory {
    param(
        [scriptblock]$ScriptBlock,
        [string]$In = $settings.OutputModulePath
    )
    $fullIn = (Resolve-Path $In).Path
    & $ScriptBlock | ForEach-Object {
        if($_ -is [string]) {
            [DirectoryInfo]::new([Path]::Combine($fullIn, $_))
        } elseif($_ -is [System.IO.DirectoryInfo]) {
            $_
        } else {
            throw "Unexpected item to copy - '$_'"
        }
    } | ForEach-Object {
        if(-not $_.Exists) { $_.Create() }
    }
}