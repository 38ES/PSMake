@{
    ModuleName = "make"
    Build = {
        Collate {
            Get-ChildItem .\functions -Recurse -File
        }
        
        CopyFiles {
            'make.psd1'
            'defaultsettings.psd1'
            'template.psd1'
        }
    }
    Clean = {
        if(test-path $settings.OutputDirectory) { remove-item $settings.OutputDirectory -Recurse }
    }
    Publish = {
        import-module moduleupdater -force
        Set-LocalRepository $settings.OutputDirectory
        if(Get-RemoteModule | where { $_.Name -eq $settings.ModuleName }) {
            Publish-LocalModuleUpdate $settings.ModuleName
        } else {
            Publish-LocalModule $settings.ModuleName
        }
        Reset-LocalRepository
    }
    Test = {
        #import-module .\make.psd1 -force
        $testFiles = Get-ChildItem .\tests -Recurse -File
        Invoke-Pester $testFiles.FullName
    }
}