@{
    Run = @{
        Path = "./tests/"
        TestExtension = ".Tests.ps1"
    }
    CodeCoverage = @{
        Enabled = $true
        OutputPath = "./CodeCoverageReport.xml"
        Path = "./functions"
        RecursePaths = $true
    }
    TestResult = @{
        Enabled = $true
        OutputFormat = "JUnitXml"
        OutputPath = "PesterTestsReport.xml"
    }
}