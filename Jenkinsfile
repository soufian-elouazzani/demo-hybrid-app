pipeline {
    agent none
    
    stages {
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
            }
        }
        
        stage('Build .NET API') {
            agent {
                docker {
                    image 'mcr.microsoft.com/dotnet/sdk:6.0'
                    args '-u root:root'
                }
            }
            steps {
                sh '''
                    echo "Building .NET app for build ${BUILD_NUMBER}"
                    
                    # Build in /tmp (writable)
                    cd /tmp
                    rm -rf MyApp
                    mkdir MyApp
                    cd MyApp
                    dotnet new console -n MyConsoleApp --force
                    cd MyConsoleApp
                    dotnet build -c Release
                    
                    echo "Build successful!"
                    
                    # Show where files are
                    echo "Build output location:"
                    ls -la bin/Release/
                    
                    # Copy to workspace for packaging
                    mkdir -p $WORKSPACE/dotnet-build
                    cp -r bin/Release/ $WORKSPACE/dotnet-build/
                    
                    echo "Files copied to workspace:"
                    ls -la $WORKSPACE/dotnet-build/
                '''
            }
        }
        
        stage('Test Database') {
            agent any
            steps {
                script {
                    sh '''
                        echo "Starting PostgreSQL container..."
                        docker run -d --name test-db \
                            -e POSTGRES_PASSWORD=test123 \
                            -e POSTGRES_USER=testuser \
                            -e POSTGRES_DB=testdb \
                            -p 5432:5432 \
                            postgres:13
                        sleep 8
                        
                        echo "Testing database connection..."
                        docker run --rm --network host \
                            -e PGPASSWORD=test123 \
                            postgres:13 psql -h localhost -U testuser -d testdb -c "
                                CREATE TABLE products (
                                    id SERIAL PRIMARY KEY,
                                    name VARCHAR(100),
                                    price DECIMAL(10,2)
                                );
                                INSERT INTO products (name, price) VALUES 
                                    ('Product A', 19.99),
                                    ('Product B', 29.99);
                                SELECT * FROM products;
                            "
                        
                        echo "Database test completed!"
                    '''
                }
            }
            post {
                always {
                    sh 'docker rm -f test-db || true'
                }
            }
        }
        
        stage('Simulate Delphi Build') {
            agent {
                docker {
                    image 'alpine:latest'
                }
            }
            steps {
                sh '''
                    echo "========================================="
                    echo "SIMULATING DELPHI BUILD"
                    echo "Build number: ${BUILD_NUMBER}"
                    echo "========================================="
                    
                    mkdir -p delphi-output
                    echo "DelphiApp.exe (simulated)" > delphi-output/README.txt
                    echo "Build number: ${BUILD_NUMBER}" >> delphi-output/README.txt
                    echo "Timestamp: $(date)" >> delphi-output/README.txt
                    echo "Target framework: Delphi 11 Alexandria (simulated)" >> delphi-output/README.txt
                    
                    # Create a fake executable
                    echo '#!/bin/bash' > delphi-output/DelphiApp.sh
                    echo 'echo "Simulated Delphi App - Build ${BUILD_NUMBER}"' >> delphi-output/DelphiApp.sh
                    chmod +x delphi-output/DelphiApp.sh
                    
                    echo "Created files:"
                    ls -la delphi-output/
                '''
            }
        }
        
        stage('Package') {
            agent any
            steps {
                sh '''
                    echo "Packaging artifacts for build ${BUILD_NUMBER}"
                    mkdir -p artifacts
                    
                    # Copy version file
                    [ -f version.json ] && cp version.json artifacts/ || echo "No version.json"
                    
                    # Copy Delphi simulation
                    [ -d delphi-output ] && cp -r delphi-output artifacts/ || echo "No delphi-output"
                    
                    # Copy .NET build (checking the correct path)
                    if [ -d dotnet-build ]; then
                        cp -r dotnet-build artifacts/dotnet-app
                        echo "Copied .NET build"
                    elif [ -d /tmp/MyApp ]; then
                        cp -r /tmp/MyApp artifacts/dotnet-source
                        echo "Copied .NET source"
                    else
                        echo "No .NET build found"
                    fi
                    
                    # Create a manifest file
                    cat > artifacts/MANIFEST.txt << EOF
Build Number: ${BUILD_NUMBER}
Build Date: $(date)
Version: $(cat version.json 2>/dev/null || echo "unknown")
Components:
  - Delphi Client (simulated)
  - .NET Console App
  - Database Scripts (PostgreSQL)
EOF
                    
                    # Create package
                    tar -czf demoapp-${BUILD_NUMBER}.tar.gz artifacts/
                    echo "Created: demoapp-${BUILD_NUMBER}.tar.gz"
                    echo "Package contents:"
                    tar -tzf demoapp-${BUILD_NUMBER}.tar.gz
                '''
                archiveArtifacts artifacts: '*.tar.gz', fingerprint: true
            }
        }
    }
    
    post {
        agent any
        always {
            echo "Pipeline finished for build ${BUILD_NUMBER}"
            cleanWs()
        }
        success {
            echo "✅ SUCCESS! Package created successfully."
        }
        failure {
            echo "❌ FAILED! Check the logs above."
        }
    }
}