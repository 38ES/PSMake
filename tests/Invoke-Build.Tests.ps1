BeforeDiscovery {
    Import-Module $PSScriptRoot\..\make.psd1 -Force
}

Describe 'Invoke-Build' {
    Context 'With build.psd1 and calling build (no other arguments)' {

        BeforeAll {
            Push-Location TestDrive:\

            $script:workingDirectory = ''
            $script:buildCalled = 0
            $script:cleanCalled = 0
            $script:publishCalled = 0
            $build = @{
                ModuleName = 'test'
                OutputDirectory = "dist"
                OutputModulePath = "dist\test"
                DefaultBuildTarget = "release"
                RestoredDependenciesPath = '.dependencies'
                Build = {{
                    $script:workingDirectory = $PWD.Path
                    $script:buildCalled++
                }}
                Clean = {{
                    $script:cleanCalled++
                }}
                Publish = {{
                    $script:publishCalled++
                }}
            }

            Mock 'Get-BuildSettings' { $build } -Verifiable -ModuleName make
            Mock 'Test-Path' { $true } -ParameterFilter { $Path -eq $build.OutputDirectory -and $PathType -eq 'Container' } -ModuleName make
            Mock 'Test-Path' { $true } -ParameterFilter { $Path -eq $build.OutputModulePath -and $PathType -eq 'Container' } -ModuleName make
            Mock 'Test-Path' { $false } -ParameterFilter { $Path -eq $build.RestoredDependenciesPath -and $PathType -eq 'Container' } -ModuleName make

            Invoke-Build
        }
        

        It "Should Call 'Get-BuildSettings' with current directory and remaining args and 'test-path' with outputdirectory and outputmodulepath" {
            Should -InvokeVerifiable
        }

        It "Should call 'Build' once" {
            $script:buildCalled | Should -BeExactly 1
        }

        It "Should set the current work directory to the current work directory before the call" {
            $workingDirectory | Should -Be "TestDrive:$([System.IO.Path]::DirectorySeparatorChar)"
        }

        It "Should call test-path twice" {
            Should -Invoke -CommandName "Test-Path" -ParameterFilter { $Path -eq $build.OutputDirectory -and $PathType -eq 'Container' } -Times 1 -ModuleName make -Scope Context
            Should -Invoke -CommandName "Test-Path" -ParameterFilter { $Path -eq $build.OutputModulePath -and $PathType -eq 'Container' } -Times 1 -ModuleName make -Scope Context
        }

        It "Should call Get-BuildSettings once" {
            Should -Invoke -CommandName "Get-BuildSettings" -Times 1 -ModuleName make -Scope Context
        }

        It "Should not call 'Clean'" {
            $cleanCalled | Should -BeExactly 0
        }

        It "Should not call 'publish'" {
            $publishCalled | Should -BeExactly 0
        }

        AfterAll {
            Pop-Location
        }
    }
}