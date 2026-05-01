pipeline {
    agent any
    
    tools {
        msbuild 'MSBuild-2022'
        dotnet 'DotNet-6.0'
    }
    
    environment {
        VERSION_FILE = 'version.json'
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Generate Version') {
            steps {
                powershell '''
                    $version = Get-Content version.json | ConvertFrom-Json
                    $version.build = $env:BUILD_NUMBER
                    $version | ConvertTo-Json | Set-Content version.json
                    Write-Host "Version: $($version.major).$($version.minor).$($version.patch).$($version.build)"
                '''
            }
        }
        
        stage('Build .NET') {
            steps {
                dir('dotnet') {
                    bat 'dotnet restore'
                    bat 'dotnet build -c Release'
                    bat 'dotnet test --no-build -c Release' // if you have tests
                    bat 'dotnet publish -c Release -o ../publish/dotnet'
                }
            }
        }
        
        stage('Build Delphi') {
            steps {
                bat '''
                    "C:\\Program Files (x86)\\Embarcadero\\Studio\\22.0\\bin\\rsvars.bat"
                    msbuild delphi\\Project1.dproj /p:Config=Release /p:Platform=Win32
                '''
            }
        }
        
        stage('Run Database Migrations') {
            steps {
                bat 'sqlcmd -S localhost -U sa -P YourPassword -i database/schema.sql'
            }
        }
        
        stage('Integration Tests') {
            steps {
                script {
                    // Start API in background
                    bat 'start /B dotnet publish/dotnet/DemoApi.dll'
                    sleep time: 5, unit: 'SECONDS'
                    
                    // Test endpoint
                    def response = bat(script: 'curl http://localhost:5000/version', returnStdout: true)
                    echo "API Response: ${response}"
                    
                    // Kill background process
                    bat 'taskkill /F /IM DemoApi.exe'
                }
            }
        }
        
        stage('Package') {
            steps {
                powershell 'scripts/package.ps1'
            }
        }
        
        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'DemoApp_*.zip', fingerprint: true
            }
        }
    }
    
    post {
        success {
            emailext (
                subject: "Build ${env.JOB_NAME} - ${env.BUILD_NUMBER} Success!",
                body: "Version available at ${env.BUILD_URL}artifact/",
                to: 'team@company.com'
            )
        }
        failure {
            emailext (
                subject: "Build ${env.JOB_NAME} - ${env.BUILD_NUMBER} Failed",
                body: "Check console output at ${env.BUILD_URL}",
                to: 'team@company.com'
            )
        }
    }
}
