[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'BuildSetting is weird and this is used internally only')]
param()

function Get-BuildSettings {
    [OutputType([Hashtable])]
    param(
        [string]$BuildFilePath,
        [string[]]$RemainingArgs
    )

    if(-not (test-path $BuildFilePath)) { throw "No $($BuildFilePath.Substring(2)) file found!" }

    $defaultData = Import-PowerShellDataFile (Join-Path $MyInvocation.MyCommand.Module.ModuleBase "defaultsettings.psd1")
    $buildSettings = @{}
    $buildSettingsAsConfigured = Import-PowerShellDataFile $BuildFilePath

    foreach($defaultKey in $defaultData.Keys) {
        $buildSettings.Add($defaultkey, $defaultData[$defaultKey])
    }

    foreach($asConfiguredKey in $buildSettingsAsConfigured.Keys) {
        $buildSettings[$asConfiguredKey] = $buildSettingsAsConfigured[$asConfiguredKey]
    }

    $buildSettings["BuildTarget"] = if($RemainingArgs -gt 0) {
        $RemainingArgs[0]
    } elseif($buildSettings.ContainsKey("DefaultBuildTarget")) {
        $buildSettings["DefaultBuildTarget"]
    } else {
        "Release"
    }

    $buildSettings["BuildTargetPath"] = Join-Path $buildSettings["OutputDirectory"] $buildSettings["BuildTarget"]

    if(-not $buildSettingsAsConfigured.ContainsKey("OutputModulePath")) {
        $buildSettings.Add("OutputModulePath", (Join-Path $buildSettings["BuildTargetPath"] $buildSettings["ModuleName"]))
    }
    # Check for required parameters
    Validate-BuildSettings $buildSettings
    $buildSettings
}