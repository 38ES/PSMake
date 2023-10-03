@{
    ModuleName = "make"
    Build = {

        CopyFiles {
            'make.psd1'
            'defaultsettings.psd1'
            'template.psd1'
            'Pester5Configuration.xml'
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

            # Removed due to code-signing requiring Smart-Card - need a soft-cert to work within Jenkins CI/CD
            # CEIG-39
            #CodeSign {
            #    'make.psd1'
            #    'make.psm1'
            #}
        }

        Debug {
            
            CopyDirectory {
                'functions'
            }

            CopyFiles {
                "make.psm1"
            }
        }
       
    }
    Clean = {
        if(test-path $settings.OutputDirectory) { remove-item $settings.OutputDirectory -Recurse }
    }
    Publish = {
        param(
            [string]$NuGetAPIKey
        )

        $args1 = @{
            Path = $settings.OutputModulePath
            Repository = '38Nexus'
        }

        if($PSBoundParameters.ContainsKey('NuGetApiKey')) {
            $args1.Add('NuGetApiKey', $NuGetAPIKey)
        }

        import-module PowerShellGet -RequiredVersion 2.2.5
        Publish-Module @args1
    }
    
    Test = {
        $PWSH = if($PSVersionTable.PSVersion.Major -gt 5) { "pwsh" } else { "powershell" }
        Start-Process $PWSH -ArgumentList @('-NoProfile', '-Command "Invoke-Pester -Configuration (Import-CliXml .\Pester5Configuration.xml) "') -NoNewWindow -Wait
    }
}