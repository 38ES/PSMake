pipeline {
    agent {
        dockerfile {
            registryUrl 'https://docker-di2e.di2e.net'
            registryCredentialsId 'CEIG-CI'
            args '-u 0:0'
        }
    }

    stages {
        stage("Output Environment") {
            steps {
                sh 'which pwsh'
                sh 'env'
                sh 'ls $PS_INSTALL_FOLDER'
                echo ".NET Core Version"
                pwsh '$PSVersionTable'
                echo 'Environment Variables'
                pwsh 'gci Env:/'
                echo 'Current Working Directory Contents'
                pwsh 'gci'
            }
        }

        stage("Build Project -- Debug") {
            when { not { branch "release" } }
            steps {
               pwsh "./jenkins-pipeline/BuildProjectDebug.ps1"
            }
        }

        stage("Build Project -- Release") {
            when { branch "release" }
            steps {
                pwsh "./jenkins-pipeline/BuildProjectRelease.ps1"
            }
        }

        stage("Test Project") {
            steps {
                pwsh "./jenkins-pipeline/TestProject.ps1"
                nunit testResultsPattern: 'PesterTestsReport.xml'
                publishCoverage adapters: [jacocoAdapter('CodeCoverageReport.xml')]
            }
        }

        stage("Create & Publish NuGet Package") {
            when { branch "release" }
            environment {
                NuGetAPIKey = credentials('CEIG_CI_NUGET_API')
                CRED = credentials("CEIG-CI")
            }
            steps {
                pwsh 'get-childitem Env:/'
                pwsh './jenkins-pipeline/CreatePublishNuGetPackage.ps1 -NuGetAPIKey $NuGetAPIKey -Username $CRED_USR -Password (ConvertTo-SecureString $CRED_PSW -AsPlainText -Force)'
            }
        }
    }
}