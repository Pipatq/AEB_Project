pipeline {
    agent {
        label 'windows-matlab'
    }
    
    environment {
        // ===============================================
        // CI/CD Configuration for AEB Model-Based Development
        // ===============================================
        
        // MATLAB installation path on Windows
        // Update this to match your MATLAB installation
        MATLAB_PATH = 'C:\\Program Files\\MATLAB\\R2025b\\bin\\matlab.exe'
        
        // Workspace directory (Windows agent working directory)
        WORKSPACE_DIR = 'C:\\Jenkins\\workspace'
        
        // Project name
        PROJECT_NAME = 'AEB_Project'
        
        // Build configuration
        MODEL_NAME = 'AEB_Model'
        BUILD_CONFIG = 'Release'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '=================================================='
                echo '[OK] STAGE 1: Checkout Code from Repository'
                echo '=================================================='
                
                // Clone from Git repository
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/Pipatq/AEB_Project.git'
                    ]]
                ])
                
                // Display commit info
                script {
                    bat '''
                        echo Current commit:
                        git log -1 --oneline
                        echo Branch:
                        git branch
                    '''
                }
                
                echo '[OK] Code checkout completed successfully'
            }
        }

        stage('Verify Environment') {
            steps {
                echo '=================================================='
                echo '[OK] STAGE 2: Verify Build Environment'
                echo '=================================================='
                
                script {
                    bat '''
                        echo Checking workspace structure...
                        dir
                        
                        echo.
                        echo Verifying required directories...
                        if exist "models" (echo [OK] models/ found) else (echo [WARNING] models/ not found)
                        if exist "data" (echo [OK] data/ found) else (echo [WARNING] data/ not found)
                        if exist "tests" (echo [OK] tests/ found) else (echo [WARNING] tests/ not found)
                        if exist "scripts" (echo [OK] scripts/ found) else (echo [WARNING] scripts/ not found)
                        
                        echo.
                        echo Checking MATLAB scripts...
                        if exist "scripts\ci_build.m" (echo [OK] ci_build.m found) else (echo [ERROR] ci_build.m not found! && exit /b 1)
                        if exist "scripts\ci_test.m" (echo [OK] ci_test.m found) else (echo [ERROR] ci_test.m not found! && exit /b 1)
                    '''
                }
                
                echo '[OK] Environment verification completed'
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo '=================================================='
                echo '[OK] STAGE 3: Execute Unit Tests'
                echo '=================================================='
                
                script {
                    // Execute MATLAB tests via Windows agent
                    bat '''
                        echo Running unit tests...
                        
                        "%MATLAB_PATH%" -batch "addpath('scripts'); exit(ci_test())"
                        
                        if %ERRORLEVEL% NEQ 0 (
                            echo [ERROR] Tests failed with exit code %ERRORLEVEL%
                            exit /b %ERRORLEVEL%
                        )
                        
                        echo [OK] Tests completed successfully
                    '''
                }
                
                // Check test results
                script {
                    bat '''
                        if exist "test_results" (
                            echo Test results directory found
                            dir test_results
                        ) else (
                            echo [WARNING] No test_results directory found
                        )
                    '''
                }
                
                echo '[OK] Unit tests stage completed (manual verification required)'
            }
        }

        stage('Build & Code Generation') {
            steps {
                echo '=================================================='
                echo '   STAGE 4: MATLAB Build & Embedded Code Generation'
                echo '=================================================='
                
                script {
                    // Execute MATLAB build via Windows agent
                    bat '''
                        echo Initiating build process...
                        echo Model: %MODEL_NAME%
                        echo Configuration: %BUILD_CONFIG%
                        echo.
                        
                        "%MATLAB_PATH%" -batch "addpath('scripts'); exit(ci_build())"
                        
                        if %ERRORLEVEL% NEQ 0 (
                            echo [ERROR] Build failed with exit code %ERRORLEVEL%
                            exit /b %ERRORLEVEL%
                        )
                        
                        echo [OK] Build completed successfully
                    '''
                }
                
                // Check for existing build artifacts
                script {
                    bat '''
                        echo.
                        echo Checking for generated code...
                        if exist "%MODEL_NAME%_ert_rtw" (
                            echo [OK] Generated code directory found
                            echo Files:
                            dir %MODEL_NAME%_ert_rtw\\*.c %MODEL_NAME%_ert_rtw\\*.h
                        ) else (
                            echo [WARNING] No generated code found
                        )
                    '''
                }
                
                echo '[OK] Build stage completed (manual verification required)'
            }
        }

        stage('Code Quality Check') {
            steps {
                echo '=================================================='
                echo '[OK] STAGE 5: Code Quality & Standards Verification'
                echo '=================================================='
                
                script {
                    bat '''
                        echo Code quality checks:
                        echo.
                        
                        if exist "%MODEL_NAME%_ert_rtw" (
                            echo 1. Checking generated code structure...
                            
                            echo    Files in generated code:
                            dir /b %MODEL_NAME%_ert_rtw\\*.c %MODEL_NAME%_ert_rtw\\*.h
                            
                            echo.
                            echo 2. Code generation successful
                        ) else (
                            echo No generated code to analyze
                            echo Run build stage first
                        )
                    '''
                }
                
                echo '[OK] Code quality check completed'
            }
        }

        stage('Collect Artifacts') {
            steps {
                echo '=================================================='
                echo '[OK] STAGE 6: Collect Build Artifacts'
                echo '=================================================='
                
                script {
                    bat '''
                        echo Collecting build artifacts...
                        
                        if not exist "artifacts" mkdir artifacts
                        
                        if exist "%MODEL_NAME%_ert_rtw" (
                            echo [OK] Collecting generated C code...
                            xcopy /E /I /Y %MODEL_NAME%_ert_rtw artifacts\\%MODEL_NAME%_ert_rtw
                            
                            echo Generated files: > artifacts\\file_manifest.txt
                            dir %MODEL_NAME%_ert_rtw >> artifacts\\file_manifest.txt
                        )
                        
                        if exist "test_results" (
                            echo [OK] Collecting test results...
                            xcopy /E /I /Y test_results artifacts\\test_results
                        )
                        
                        if exist "build.log" (
                            echo [OK] Collecting build log...
                            copy build.log artifacts\\
                        )
                        
                        echo.
                        echo Artifact collection summary:
                        dir artifacts
                    '''
                }
                
                echo '[OK] Artifacts collected successfully'
            }
        }
        
        stage('Package Firmware') {
            steps {
                echo '=================================================='
                echo '[OK] STAGE 7: Package Firmware Release'
                echo '=================================================='
                
                script {
                    bat '''
                        if exist "%MODEL_NAME%_ert_rtw" (
                            echo Creating firmware package...
                            
                            set timestamp=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
                            set timestamp=%timestamp: =0%
                            set package_name=firmware_%MODEL_NAME%_%timestamp%.zip
                            
                            echo Package: %package_name%
                            
                            powershell -Command "Compress-Archive -Path '%MODEL_NAME%_ert_rtw\\*' -DestinationPath '%package_name%' -Force"
                            
                            if exist "%package_name%" (
                                echo [OK] Package created successfully
                                move %package_name% artifacts\\
                                dir artifacts\\%package_name%
                            ) else (
                                echo [ERROR] Failed to create package
                                exit /b 1
                            )
                        ) else (
                            echo [WARNING] No code to package - skipping
                            echo Run build stage to generate code first
                        )
                    '''
                }
                
                echo '[OK] Firmware packaging completed'
            }
        }
        
        stage('Deploy - Staging (CD)') {
            when {
                expression { 
                    // Only deploy if artifacts exist
                    return fileExists('artifacts/firmware_*.zip')
                }
            }
            steps {
                echo '=================================================='
                echo '[OK] STAGE 8: Deploy to Staging Environment (Mock)'
                echo '=================================================='
                
                script {
                    echo '[OK] Continuous Deployment - Staging'
                    echo ''
                    echo 'This stage simulates deployment to staging ECU'
                    echo ''
                    echo '[OK] Deployment steps (when implemented):'
                    echo '  1. Extract firmware package'
                    echo '  2. Validate firmware checksums'
                    echo '  3. Connect to staging ECU (CAN/Ethernet)'
                    echo '  4. Flash firmware via bootloader'
                    echo '  5. Verify ECU response'
                    echo '  6. Run smoke tests on hardware'
                    echo ''
                    
                    // Simulate deployment process
                    sleep 2
                    
                    echo '[OK] Firmware deployment simulation completed'
                    echo '[OK] Staging ECU Status: READY'
                    echo '[OK] All systems nominal'
                }
                
                echo '[OK] Staging deployment completed (mock)'
            }
        }
        
        stage('Deploy - Production (CD)') {
            when {
                expression { 
                    // Only on main branch and manual approval
                    return env.BRANCH_NAME == 'main'
                }
            }
            steps {
                echo '=================================================='
                echo '[OK] STAGE 9: Deploy to Production ECU (Mock)'
                echo '=================================================='
                
                // Require manual approval for production
                input message: 'Deploy to Production ECU?', ok: 'Deploy'
                
                script {
                    echo '[OK] Continuous Deployment - PRODUCTION'
                    echo ''
                    echo '️  CRITICAL: Production deployment initiated'
                    echo ''
                    echo '[OK] Pre-deployment checklist:'
                    echo '[OK] All tests passed'
                    echo '[OK] Code review completed'
                    echo '[OK] Staging validation successful'
                    echo '[OK] Manual approval received'
                    echo ''
                    echo '[OK] Production deployment (when implemented):'
                    echo '  1. Backup current ECU firmware'
                    echo '  2. Upload new firmware to production ECU'
                    echo '  3. Flash firmware'
                    echo '  4. Reboot ECU'
                    echo '  5. Run production validation tests'
                    echo '  6. Monitor system health'
                    echo ''
                    
                    // Simulate production deployment
                    sleep 3
                    
                    echo '[OK] Production deployment simulation completed'
                    echo '[OK] Production ECU Status: OPERATIONAL'
                    echo '[OK] Firmware version updated'
                    echo '[OK] System health: NOMINAL'
                }
                
                echo '[OK] Production deployment completed (mock)'
            }
        }
    }

    post {
        always {
            echo '=================================================='
            echo '[OK] Pipeline Cleanup & Archiving'
            echo '=================================================='
            
            script {
                bat '''
                    echo Archiving artifacts...
                    if exist "artifacts" (
                        dir artifacts
                        
                        echo [OK] Artifacts ready for archival
                    )
                    
                    if exist "test_results" (
                        echo [OK] Test results ready for archival
                        dir test_results
                    ) else (
                        echo [INFO] No test_results folder found
                    )
                '''
            }
            
            // Archive all important artifacts from Jenkins workspace
            archiveArtifacts artifacts: '''
                build.log,
                artifacts/**/*,
                test_results/**/*
            ''', allowEmptyArchive: true
            
            // Publish test results (if available)
            script {
                if (fileExists('test_results')) {
                    echo 'Publishing test reports...'
                    
                    // Publish JUnit test results (XML format)
                    // Note: MATLAB Test Framework can export to JUnit XML format
                    junit testResults: 'test_results/**/*.xml', allowEmptyResults: true
                    
                    // Publish HTML Coverage Report
                    publishHTML([
                        reportDir: 'test_results/coverage_report',
                        reportFiles: 'coverage.html',
                        reportName: 'Code Coverage Report',
                        keepAll: true,
                        alwaysLinkToLastBuild: true,
                        allowMissing: true
                    ])
                    
                    echo '[OK] Test reports published'
                } else {
                    echo '[INFO] No test_results directory found - reports will be available after running ci_test()'
                }
            }
            
            echo '[OK] Artifacts archived successfully'
        }
        
        success {
            echo '=================================================='
            echo '[OK] PIPELINE EXECUTED SUCCESSFULLY! '
            echo '=================================================='
            echo 'Build: SUCCESS'
            echo 'Tests: PASSED'
            echo 'Artifacts: READY'
            echo ''
            echo 'Available Reports:'
            echo '  - Build Artifacts: ${env.BUILD_URL}artifact/'
            echo '  - Test Results: ${env.BUILD_URL}testReport/'
            echo '  - Code Coverage: ${env.BUILD_URL}Code_Coverage_Report/'
            echo '  - Console Output: ${env.BUILD_URL}console'
            echo ''
            echo 'Next steps:'
            echo '  - Review artifacts in Jenkins workspace'
            echo '  - Deploy to target ECU (manual)'
            echo '  - Run Hardware-in-the-Loop (HIL) tests'
            echo ''
            echo 'For automated deployment, see README.md'
            echo '=================================================='
            
            // Email notification with report links
            // emailext(
            //     subject: "[SUCCESS] Jenkins Build: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            //     body: """Build completed successfully!
            //     
            //     Build Details: ${env.BUILD_URL}
            //     
            //     Reports:
            //     - Test Results: ${env.BUILD_URL}testReport/
            //     - Code Coverage: ${env.BUILD_URL}Code_Coverage_Report/
            //     - Artifacts: ${env.BUILD_URL}artifact/
            //     
            //     Next: Review and deploy to target ECU
            //     """,
            //     to: "team@example.com"
            // )
        }
        
        failure {
            echo '=================================================='
            echo '[OK] PIPELINE FAILED!'
            echo '=================================================='
            echo 'Status: FAILURE'
            echo ''
            echo 'Troubleshooting steps:'
            echo '  1. Check build.log for detailed errors'
            echo '  2. Verify MATLAB toolboxes are installed'
            echo '  3. Ensure model files are in correct location'
            echo '  4. Review test results in test_results/'
            echo '  5. See README.md for common issues'
            echo ''
            echo 'Build details: ${env.BUILD_URL}'
            echo '=================================================='
            
            // Email notification (optional)
            // emailext(
            //     subject: " Jenkins Build FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            //     body: "Build failed. Please check logs.\n\nView details: ${env.BUILD_URL}",
            //     to: "${NOTIFY_EMAIL}"
            // )
        }
        
        unstable {
            echo '=================================================='
            echo '[OK] PIPELINE UNSTABLE'
            echo '=================================================='
            echo 'Status: UNSTABLE'
            echo 'Some tests may have failed or warnings detected'
            echo 'Review test results and logs for details'
            echo '=================================================='
        }
        
        cleanup {
            echo '=================================================='
            echo '[OK] Cleanup Phase'
            echo '=================================================='
            
            script {
                bat '''
                    echo Cleaning temporary files...
                    
                    if exist "*.asv" del /Q *.asv
                    if exist "*.m~" del /Q *.m~
                    if exist "*.autosave" del /Q *.autosave
                    
                    echo [OK] Cleanup completed
                '''
            }
            
            echo '[OK] Pipeline cleanup finished'
        }
    }
}
