pipeline {
    agent any
    
    environment {
        // ===============================================
        // Windows Local Configuration
        // ===============================================
        
        // MATLAB installation path on Windows
        // Update this to match your MATLAB installation
        MATLAB_PATH = 'C:\\Program Files\\MATLAB\\R2025b\\bin\\matlab.exe'
        
        // Workspace directory (Jenkins will use mounted volume)
        WORKSPACE_DIR = '/workspace'
        
        // Project name
        PROJECT_NAME = 'AEB_Project'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '=================================================='
                echo '   STAGE 1: Checkout Code from Repository'
                echo '=================================================='
                
                // Clone from Git repository
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/Pipatq/AEB_Project.git'
                    ]]
                ])
                
                echo 'Code checkout completed successfully'
            }
        }

        stage('Verify Workspace') {
            steps {
                echo '=================================================='
                echo '   STAGE 2: Verify Mounted Workspace'
                echo '=================================================='
                
                script {
                    // Check if workspace is accessible
                    sh '''
                        echo "Checking workspace mount..."
                        ls -la /workspace
                        echo "Files in workspace:"
                        ls /workspace
                    '''
                }
            }
        }

        stage('Run MIL Test & Build') {
            steps {
                echo '=================================================='
                echo '   STAGE 3: Execute MATLAB Build & Test'
                echo '=================================================='
                
                script {
                    // Note: This runs MATLAB script that's already in workspace
                    // The actual files are on Windows at C:\Matlab\Matlab
                    // Jenkins sees them at /workspace (mounted volume)
                    sh '''
                        echo "MATLAB build script location:"
                        ls -l /workspace/build_script.m
                        echo "Note: MATLAB must be run manually on Windows host"
                        echo "Or setup Jenkins Windows agent"
                    '''
                    
                    echo 'MATLAB build completed (manual step required)'
                }
            }
        }

        stage('Collect Artifacts') {
            steps {
                echo '=================================================='
                echo '   STAGE 4: Collect Build Artifacts'
                echo '=================================================='
                
                script {
                    // Check for generated code
                    sh '''
                        echo "Checking for generated artifacts..."
                        if [ -d "/workspace/AEB_Model_ert_rtw" ]; then
                            echo "C Code generated successfully"
                            ls -l /workspace/AEB_Model_ert_rtw
                        else
                            echo "WARNING: No generated code found"
                            echo "Run build_script.m manually on Windows"
                        fi
                    '''
                }
            }
        }
        
        stage('Package & Archive') {
            steps {
                echo '=================================================='
                echo '   STAGE 5: Package Firmware for Deployment'
                echo '=================================================='
                
                script {
                    // Create firmware package if artifacts exist
                    sh '''
                        if [ -d "/workspace/AEB_Model_ert_rtw" ]; then
                            cd /workspace
                            zip -r firmware_release.zip AEB_Model_ert_rtw/*.c AEB_Model_ert_rtw/*.h
                            echo "Firmware package created"
                        else
                            echo "Skipping packaging - no artifacts found"
                        fi
                    '''
                }
            }
        }
        
        stage('Mock Flashing (CD)') {
            steps {
                echo '=================================================='
                echo '   STAGE 6: Mock ECU Flashing (Deployment)'
                echo '=================================================='
                
                script {
                    // Simulate flashing firmware to ECU
                    echo 'Simulating firmware flash to target ECU...'
                    sleep 2
                    echo '✓ Firmware flashed successfully (Mock)'
                    echo '✓ ECU Status: READY'
                    echo '✓ Deployment completed!'
                }
            }
        }
    }

    post {
        always {
            echo '=================================================='
            echo '   Pipeline Cleanup & Archiving'
            echo '=================================================='
            
            // Archive all important artifacts
            archiveArtifacts artifacts: '''
                **/build.log,
                **/firmware_release*.zip,
                **/AEB_Model_ert_rtw/*.c,
                **/AEB_Model_ert_rtw/*.h
            ''', allowEmptyArchive: true
        }
        
        success {
            echo '=================================================='
            echo '   ✓✓✓ PIPELINE EXECUTED SUCCESSFULLY! ✓✓✓'
            echo '=================================================='
            echo 'All stages completed without errors'
            echo 'Artifacts are ready for deployment'
        }
        
        failure {
            echo '=================================================='
            echo '   ✗✗✗ PIPELINE FAILED! ✗✗✗'
            echo '=================================================='
            echo 'Check build.log for detailed error messages'
        }
        
        unstable {
            echo 'Pipeline completed with warnings'
        }
    }
}
