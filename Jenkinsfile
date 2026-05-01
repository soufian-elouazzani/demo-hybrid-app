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
                    echo "In real company: Windows container would run here"
                    echo "MSBuild would compile .dproj file"
                    echo "========================================="
                    
                    # Create fake Delphi output
                    mkdir -p delphi-output
                    echo "DelphiApp.exe (simulated)" > delphi-output/README.txt
                    echo "build: ${BUILD_NUMBER}" >> delphi-output/README.txt
                '''
                stash name: 'delphi', includes: 'delphi-output/**/*'
            }
        }
        // Stage 3: Run database test (spins up PostgreSQL)
                // Stage 3: Run database test (spins up PostgreSQL)
        stage('Test Database') {
            agent any  // runs on Jenkins master
            steps {
                script {
                    // Start PostgreSQL container with password
                    sh '''
                        docker run -d --name test-db \
                            -e POSTGRES_PASSWORD=test123 \
                            -e POSTGRES_USER=testuser \
                            -e POSTGRES_DB=testdb \
                            -p 5432:5432 \
                            postgres:13
                        sleep 5
                    '''
                    
                    // Test connection with username and password
                    sh '''
                        docker run --rm --network host \
                            -e PGPASSWORD=test123 \
                            postgres:13 psql -h localhost -U testuser -d testdb -c "SELECT version();"
                    '''
                    
                    // Create a test table
                    sh '''
                        docker run --rm --network host \
                            -e PGPASSWORD=test123 \
                            postgres:13 psql -h localhost -U testuser -d testdb -c "
                                CREATE TABLE test_table (
                                    id SERIAL PRIMARY KEY,
                                    name VARCHAR(100),
                                    created_at TIMESTAMP DEFAULT NOW()
                                );
                                INSERT INTO test_table (name) VALUES ('test1'), ('test2');
                                SELECT * FROM test_table;
                            "
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
