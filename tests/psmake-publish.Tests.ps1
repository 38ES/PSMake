[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','', Justification = 'Pester Tests use variables outside standard scope')]
param()

BeforeDiscovery {
    Import-Module $PSScriptRoot\..\PSMake.psd1 -Force
}

Describe 'Make-Publish' {

    BeforeAll {
        $fileContents = @"
@{
    ModuleName = 'test'
    Build = { 'Build Invoked' }
    Clean = { 'Clean Invoked' }
    Publish = { param([string]`$arg) "Published with: `$arg" }
}
"@
        # Arrange
        $fileContents | Out-File TestDrive:\build.psd1
        New-ModuleManifest -Path TestDrive:\test.psd1 -RootModule 'test.psm1'
        Push-Location TestDrive:\
    }

    Context 'Is Invoked without args' {
        BeforeAll {
            $output = Invoke-PSMake publish
        }

        It "Should call 'Publish' scriptblock of build.psd1" {
            $output | Should -Be "Published with: "
        }
    }

    Context 'Is Invoked With Args' {
        BeforeAll {
            $output = Invoke-PSMake publish 'myApiKey'
        }

        It "Should call 'Publish' scriptblock of build.psd1 with args" {
            $output | Should -Be "Published with: myApiKey"
        }
    }

    AfterAll {
        Pop-Location
    }
}
