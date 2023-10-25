function GetPlatformEnvironment {
    [CmdletBinding()]
    param()

    [System.OperatingSystem]$OS = [System.Environment]::OSVersion

    return [PSCustomObject]@{
        Platform = $OS.Platform
        OSVersion = [Version]($OS.Version)
        OSVersionString = $OS.VersionString
        PSVersion = [Version]($PSVersionTable.PSVersion)
    }
    
}