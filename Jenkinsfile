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

        stage('Verify MATLAB Installation') {
            steps {
                echo '=================================================='
                echo '   STAGE 2: Verify MATLAB is Accessible'
                echo '=================================================='
                
                script {
                    // Check if MATLAB is accessible from Windows host
                    bat """
                        echo Checking MATLAB installation...
                        if exist "${MATLAB_PATH}" (
                            echo MATLAB found at ${MATLAB_PATH}
                        ) else (
                            echo ERROR: MATLAB not found!
                            exit /b 1
                        )
                    """
                }
            }
        }

        stage('Run MIL Test & Build') {
            steps {
                echo '=================================================='
                echo '   STAGE 3: Execute MATLAB Build & Test'
                echo '=================================================='
                
                script {
                    // Execute MATLAB build script on Windows host
                    // Jenkins calls Windows MATLAB directly
                    bat """
                        cd C:\\Matlab\\Matlab
                        "${MATLAB_PATH}" -batch "build_script" -logfile build.log
                    """
                    
                    echo 'MATLAB build and test completed'
                }
            }
        }

        stage('Collect Artifacts') {
            steps {
                echo '=================================================='
                echo '   STAGE 4: Collect Build Artifacts'
                echo '=================================================='
                
                script {
                    // Copy artifacts to Jenkins workspace
                    bat """
                        echo Collecting artifacts...
                        if exist C:\\Matlab\\Matlab\\AEB_Model_ert_rtw (
                            echo C Code generated successfully
                        ) else (
                            echo WARNING: No generated code found
                        )
                    """
                }
            }
        }
        
        stage('Package & Archive') {
            steps {
                echo '=================================================='
                echo '   STAGE 5: Package Firmware for Deployment'
                echo '=================================================='
                
                script {
                    // Create firmware package
                    def timestamp = new Date().format('yyyyMMdd_HHmmss')
                    def firmwareName = "firmware_release_${timestamp}.zip"
                    
                    bat """
                        cd C:\\Matlab\\Matlab
                        powershell -Command "Compress-Archive -Path AEB_Model_ert_rtw\\*.c,AEB_Model_ert_rtw\\*.h -DestinationPath ${firmwareName} -Force"
                    """
                    
                    echo "Firmware package created: ${firmwareName}"
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
            
            // Archive all important artifacts from Windows path
            script {
                bat """
                    echo Archiving artifacts...
                    if exist C:\\Matlab\\Matlab\\build.log (
                        copy C:\\Matlab\\Matlab\\build.log .
                    )
                    if exist C:\\Matlab\\Matlab\\firmware_release_*.zip (
                        copy C:\\Matlab\\Matlab\\firmware_release_*.zip .
                    )
                """
            }
            
            // Archive using Jenkins
            archiveArtifacts artifacts: '''
                build.log,
                firmware_release_*.zip,
                AEB_Model_ert_rtw/*.c,
                AEB_Model_ert_rtw/*.h
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
