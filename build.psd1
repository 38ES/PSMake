@{
    ModuleName = "make"
    Build = {

        CopyFiles {
            'make.psd1'
            'defaultsettings.psd1'
            'template.psd1'
        }

        Release {

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
            Repository = 'Di2e'
        }

        if($PSBoundParameters.ContainsKey('NuGetApiKey')) {
            $args1.Add('NuGetApiKey', $NuGetAPIKey)
        }

        import-module PowerShellGet -RequiredVersion 2.2.5
        Publish-Module @args1
    }
    
    Test = {
        #import-module .\make.psd1 -force
        $testFiles = Get-ChildItem .\tests -Recurse -File
        Invoke-Pester $testFiles.FullName `
            -OutputFile ./PesterTestsReport.xml -OutputFormat NUnitXml `
            -CodeCoverageOutputFile ./CodeCoverageReport.xml -CodeCoverageOutputFileFormat JaCoCo -CodeCoverage (Get-ChildItem ./functions/* -File -Recurse).FullName
    }
}