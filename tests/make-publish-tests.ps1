# Tests for 'make' (Invoke-Build) publish
using module "..\make.psm1"

Describe 'Make-Publish' {
    Context 'Is Invoked' {
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
            Push-Location TestDrive:\
        }

        $output = Invoke-Build publish
        

        It "Should call 'Publish' scriptblock of build.psd1" {
            $output | Should -Be "Published with: "
        }

        $output = Invoke-Build publish 'myApiKey'

        It "Should call 'Publish' scriptblock of build.psd1 with args" {
            $output | Should -Be "Published with: myApiKey"
        }

        AfterAll {
            Pop-Location
        }
        
    }
}
