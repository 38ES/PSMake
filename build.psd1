@{
    ModuleName = "PSMake"
    Credential = $null
    DevRequiredModules = @(
        @{
            ModuleName = "Pester"
            ModuleVersion = "5.5.0"
        }
    )
    Build = {

        CopyFiles {
            'PSMake.psd1'
            'defaultsettings.psd1'
            'template.psd1'
            'Pester5Configuration-cicd.psd1'
            'Pester5Configuration-local.psd1'
            'LICENSE'
        }

        Prerelease {
            SetPrereleaseTag {
                'PSMake.psd1'
            }
        }

        Release {

            CustomCode {
                # Import System.Security from GAC if Windows PowerShell is being used
                if ( ([version]$PSVersionTable.PSVersion).Major -lt 6) {
                    $asm = [System.Reflection.Assembly]::LoadWithPartialName('System.Security')
                    if ($null -eq $asm) {
                        throw 'Unable to load System.Security from GAC for Windows PowerShell'
                    }
                }
            }

            Collate {
                Get-ChildItem .\functions -Recurse -File
            }
        } -AndPrerelease

        Debug {

            CopyDirectory {
                'functions'
            }

            CopyFiles {
                "PSMake.psm1"
            }
        }

    }

    Clean = {
        if(test-path $settings.OutputDirectory) { remove-item $settings.OutputDirectory -Recurse }
    }

    Publish = {
        [CmdletBinding()]
        param(
            [string]$NuGetAPIKey
        )
        Write-Verbose "Publish module at $($settings.OutputModulePath)"
        $args1 = @{
            Path = $settings.OutputModulePath
            Repository = if ($env:POWERSHELL_REPO_NAME) { $env:POWERSHELL_REPO_NAME } else { '38Nexus' }
        }

        if($PSBoundParameters.ContainsKey('NuGetApiKey')) {
            $args1.Add('NuGetApiKey', $NuGetAPIKey)
        }

        if ($settings.Credential -is [pscredential]) {
            Write-Verbose "Adding provided credential - user: $($settings.Credential.UserName)"
            $args1.Add("Credential", $settings.Credential)
        }

        Publish-Module @args1
    }

    Test = {
        param(
            [Parameter(Position = 1)]
            [string]$ReportType
        )
        if($PSBoundParameters.ContainsKey("ReportType") -and ($ReportType -eq "cicd" -or $ReportType -eq 'reports')) {
            Write-Verbose 'Running Pester tests for CI/CD pipeline'
            Invoke-Pester -Configuration (Import-PowerShellDataFile .\Pester5Configuration-cicd.psd1)
        }
        else {
            Write-Verbose 'Rnning Pester tests for local system'
            Invoke-Pester -Configuration (Import-PowerShellDataFile .\Pester5Configuration-local.psd1)
        }
    }
}