using namespace System.IO

function RestoreDependencies {
    [CmdletBinding()]
    param(
        $RequiredModules = (Import-PowerShellDataFile "$($settings.ModuleName).psd1").RequiredModules,
        $OutputDirectory = ".dependencies",
        $AllowPrerelease = $false,
        [pscredential]$Credential = (GetRestoreCredential)
    )

    if (-not $RequiredModules) { return }

    if (-not (test-path $OutputDirectory)) {
        new-item -Path $OutputDirectory -ItemType Directory | Out-Null
    }

    Write-Verbose "Getting credential"
        
    # Ensure dependencies are installed before importing the module
    Write-Verbose "Restoring Dependencies..."
    $RequiredModules | ForEach-Object {
        $module = $_
        $moduleInfo = @{}
        if ($module -is [string]) {
            $moduleInfo.Add("Name", $module)
        }
        else {
            $moduleInfo.Add("Name", $module.ModuleName)
            if($module.ContainsKey("ModuleVersion")) {
                $moduleInfo.Add("MinimumVersion", $module.ModuleVersion)
            }
            elseif ($module.ContainsKey("RequiredVersion")) {
                $moduleInfo.Add("RequiredVersion", $module.RequiredVersion)
            }
        }
        if ($PSBoundParameters.ContainsKey("AllowPrerelease")) {
            $moduleInfo.Add("AllowPrerelease", $AllowPrerelease)
        }
        
        $moduleInfo.Add("ErrorAction", "Stop")
        
        if($Credential) {
            $moduleInfo.Add("Credential", $Credential)
        }
       
        Write-Verbose "Restoring Module '$($moduleInfo.Name)'$(if($moduleInfo.RequiredVersion) { ", RequiredVersion = $($moduleInfo.RequiredVersion)"})$(if($moduleInfo.MinimumVersion) { ", MinimumVersion = $($moduleInfo.MinimumVersion)"})$(if($Credential) { " using username $($Credential.UserName)" })"
        $foundModule = Find-Module @moduleInfo | Select -First 1
        $installedModulePath = [Path]::Combine($OutputDirectory, $foundModule.Name, $foundModule.Version.Split('-')[0])
        $installedModuleInfoPath = [Path]::Combine($installedModulePath, 'PSGetModuleInfo.xml')

        if (-not (test-path $installedModuleInfoPath) -or $foundModule.Version -ne ((Import-CliXml $installedModulePath\PSGetModuleInfo.xml)).Version) {

            Write-Verbose "Module $($foundModule.Name) ($($foundModule.Version)) not installed... installing."
            $SaveArgs = @{
                Name = $foundModule.Name
                Path = $OutputDirectory
                RequiredVersion = $foundModule.Version.ToString()
                Repository = $foundModule.Repository
                ErrorAction = 'Stop'
                Force = $true
            }
            if ($AllowPrerelease) {
                $SaveArgs.Add("AllowPrerelease", $AllowPrerelease)
            }
            if ($Credential) {
                $SaveArgs.Add("Credential", $Credential)
            }
            Save-Module @SaveArgs

            # This is a workaround for Pester tests not able to use C# types of imported binaries from the saved module
            #$importPath = [Path]::Combine($OutputDirectory, $foundModule.Name, $foundModule.Version.Split('-')[0], "$($foundModule.Name).psd1")
            #Import-Module $importPath -Force -Global
        }

        Write-Verbose "Using Module - $($foundModule.Name) $($foundModule.Version)"
    }
}

