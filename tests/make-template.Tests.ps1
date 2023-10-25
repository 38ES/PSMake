BeforeDiscovery {
    Import-Module $PSScriptRoot\..\make.psd1 -Force
}

Describe 'Make-Template' {
    Context 'Is Invoked' {
        BeforeAll {
            Push-Location TestDrive:\
            Invoke-Build template example
        }
        
        It "Should create a folder for the module" {
            (test-path .\example -PathType Container) | Should -BeTrue
        }

        It "Should create a tests folder in the module project" {
            (test-path .\example\tests -PathType Container) | Should -BeTrue
        }

        It "Should create a functions folder in the module project" {
            (test-path .\example\functions -PathType Container) | Should -BeTrue
        }

        It "Should create a powershell module file in the module project" {
            (test-path .\example\example.psm1 -PathType Leaf) | Should -BeTrue
        }

        It "Should create a build.psd1 file in the module project" {
            (test-path .\example\build.psd1 -PathType Leaf) | Should -BeTrue
        }

        It 'Should create a Pester5Configuration-local.psd1 file' {
            (test-path .\example\Pester5Configuration-local.psd1 -PathType Leaf) | Should -BeTrue
        }

        It 'Should create a Pester5Configuration-cicd.psd1 file' {
            (test-path .\example\Pester5Configuration-cicd.psd1 -PathType Leaf) | Should -BeTrue
        }

        AfterAll {
            Pop-Location
        }
        
    }
}