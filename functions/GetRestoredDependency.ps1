function GetRestoredDependency {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,
        [string]$ModuleVersion,
        [string]$RequiredVersion,
        [Parameter(Mandatory = $true)]
        [string]$PSModuleDirectory
    )

    if (-not (Test-Path $PSModuleDirectory -PathType Container)) {
        throw "PSModuleDirectory path '$PSModuleDirectory' does not exist or is not a folder."
    }

    $requiredVersion = $null
    if($RequiredVersion) {
        [Version]::TryParse($RequiredVersion, [ref]$requiredVersion) | Out-Null
    }

    $moduleVersion = $null
    if ($ModuleVersion) {
        [Version]::TryParse($ModuleVersion, [ref]$moduleVersion) | Out-Null
    }

    Get-ChildItem -Path (Join-Path $PSModuleDirectory $ModuleName) -Directory -ErrorAction SilentlyContinue | `
    Where-Object {
        $Version = $null
        if ([Version]::TryParse($_.Name, [ref]$Version)) {
            if($requiredVersion) {
                $Version -eq $requiredVersion
            }
            elseif ($moduleVersion) {
                $Version -ge $moduleVersion -and $Version.Major -eq $moduleVersion.Major
            }
            else {
                $true
            }
        }
        else {
            $false
        }
    } | `
    Sort-Object -Descending -Property "Name" | `
    Select-Object -First 1 | `
    Select-Object -ExpandProperty FullName | `
    ForEach-Object {
        Import-PowerShellDataFile -Path (Join-Path $_ "$ModuleName.psd1") -ErrorAction SilentlyContinue | `
        ForEach-Object {
            $_.Add("Name", $ModuleName)
            $_.Add("Version", $_.ModuleVersion)
            Write-Output $_
        }
    }
}
