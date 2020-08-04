function Get-BuildSettings {
    param(
        [string]$BuildFilePath
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
    if(-not $buildSettingsAsConfigured.ContainsKey("OutputModulePath")) {
        $buildSettings.Add("OutputModulePath", (Join-Path $buildSettings["OutputDirectory"] $buildSettings["ModuleName"]))
    }
    # Check for required parameters
    Validate-BuildSettings $buildSettings
    $buildSettings
}