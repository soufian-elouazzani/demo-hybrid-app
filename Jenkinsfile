pipeline {
    // No global agent - each stage defines its own container
    agent  none 
    stages {
        // Stage 1: Generate version (uses tiny alpine container)
        stage('Generate Version') {
            agent {
                docker {
                    image 'alpine:latest'
                }
            }
            steps {
                sh '''
                    echo "{\\"version\\": \\"1.0.${BUILD_NUMBER}\\"}" > version.json
                    cat version.json
                '''
                stash name: 'version', includes: 'version.json'
            }
        }
        
        // Stage 2: Build .NET API (uses .NET container)
        stage('Build .NET API') {
            agent {
                docker {
                    image 'mcr.microsoft.com/dotnet/sdk:6.0'
                }
            }
            steps {
                unstash 'version'
                sh '''
                    mkdir -p src
                    echo 'Console.WriteLine("Hello from .NET");' > src/Program.cs
                    dotnet new console -n MyApp -o src
                    cd src && dotnet build
                '''
                stash name: 'build', includes: 'src/**/*'
            }
        }
        
        // Stage 3: Run database test (spins up PostgreSQL)
        stage('Test Database') {
            agent any  // runs on Jenkins master
            steps {
                script {
                    // Start PostgreSQL container
                    sh '''
                        docker run -d --name test-db \
                            -e POSTGRES_PASSWORD=test \
                            -p 5432:5432 \
                            postgres:13
                        sleep 5
                    '''
                    
                    // Test connection from another container
                    sh '''
                        docker run --rm --network host \
                            postgres:13 psql -h localhost -U postgres -c "SELECT version();"
                    '''
                }
            }
            post {
                always {
                    sh 'docker rm -f test-db || true'
                }
            }
        }
        
        // Stage 4: Package artifacts
        stage('Package') {
            agent any
            steps {
                unstash 'version'
                unstash 'build'
                sh '''
                    mkdir -p artifacts
                    cp version.json artifacts/
                    cp -r src/MyApp/bin artifacts/
                    tar -czf demoapp-${BUILD_NUMBER}.tar.gz artifacts/
                '''
                archiveArtifacts '*.tar.gz'
            }
        }
    }
}
