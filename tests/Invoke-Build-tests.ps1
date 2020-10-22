InModuleScope 'make' {
    Describe 'Invoke-Build' {
        Context 'With build.psd1 and calling build (no other arguments)' {
            Push-Location TestDrive:\

            $workingDirectory = ''
            $buildCalled = 0
            $cleanCalled = 0
            $publishCalled = 0
            $build = @{
                ModuleName = 'test'
                OutputDirectory = "dist"
                OutputModulePath = "dist\test"
                DefaultBuildTarget = "release"
                Build = {{
                    $workingDirectory = $PWD.Path
                    $buildCalled++
                }}
                Clean = {{
                    $cleanCalled++
                }}
                Publish = {{
                    $publishCalled++
                }}
            }

            Mock 'Get-BuildSettings' { $build } -Verifiable
            Mock 'test-path' { $true } -Verifiable -ParameterFilter { $Path -eq $build.OutputDirectory -and $PathType -eq 'Container' }
            Mock 'test-path' { $true } -Verifiable -ParameterFilter { $Path -eq $build.OutputModulePath -and $PathType -eq 'Container' }


            Invoke-Build

            It "Should Call 'Get-BuildSettings' with current directory and remaining args and 'test-path' with outputdirectory and outputmodulepath" {
                Assert-VerifiableMock
            }

            It "Should call 'Build' once" {
                $buildCalled | Should -BeExactly 1
            }

            It "Should set the current work directory to the current work directory before the call" {
                $workingDirectory | Should -Be "TestDrive:\"
            }

            It "Should call test-path twice" {
                Assert-MockCalled 'test-path' -Times 2
            }

            It "Should call Get-BuildSettings once" {
                Assert-MockCalled 'Get-BuildSettings' -Times 2
            }

            It "Should not call 'Clean'" {
                $cleanCalled | Should -BeExactly 0
            }

            It "Should not call 'publish'" {
                $publishCalled | Should -BeExactly 0
            }

            Pop-Location
        }
    }
}