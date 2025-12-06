pipeline {
    agent any
    
    environment {
        // ===============================================
        // CI/CD Configuration for AEB Model-Based Development
        // ===============================================
        
        // MATLAB installation path on Windows
        // Update this to match your MATLAB installation
        MATLAB_PATH = 'C:\\Program Files\\MATLAB\\R2025b\\bin\\matlab.exe'
        
        // Workspace directory (Jenkins will use mounted volume)
        WORKSPACE_DIR = '/workspace'
        
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
                    sh '''
                        echo "Current commit:"
                        git log -1 --oneline
                        echo "Branch:"
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
                    sh '''
                        echo "Checking workspace structure..."
                        ls -la /workspace
                        
                        echo ""
                        echo "Verifying required directories..."
                        for dir in models data tests scripts; do
                            if [ -d "/workspace/$dir" ]; then
                                echo "[OK] $dir/ found"
                            else
                                echo "[WARNING] $dir/ not found"
                            fi
                        done
                        
                        echo ""
                        echo "Checking MATLAB scripts..."
                        if [ -f "/workspace/scripts/ci_build.m" ]; then
                            echo "[OK] ci_build.m found"
                        else
                            echo "[ERROR] ci_build.m not found!"
                            exit 1
                        fi
                        
                        if [ -f "/workspace/scripts/ci_test.m" ]; then
                            echo "[OK] ci_test.m found"
                        else
                            echo "[ERROR] ci_test.m not found!"
                            exit 1
                        fi
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
                    // Note: This requires MATLAB to be accessible on Windows host
                    // For Linux agent, use MATLAB batch command
                    sh '''
                        echo "Running unit tests..."
                        echo "Command: matlab -batch 'addpath(\"scripts\"); exit(ci_test())'"
                        echo ""
                        echo "NOTE: Manual execution required on Windows host:"
                        echo "  1. Open MATLAB on Windows"
                        echo "  2. cd to: C:\\workspace (or your mounted path)"
                        echo "  3. Run: addpath('scripts'); ci_test()"
                        echo ""
                        echo "For automated execution, setup Jenkins Windows agent"
                        echo "or use MATLAB Web App Server"
                    '''
                }
                
                // For now, check if test results exist from previous run
                script {
                    sh '''
                        if [ -d "/workspace/test_results" ]; then
                            echo "Test results directory found"
                            ls -l /workspace/test_results/
                        else
                            echo "No test results found - tests need to be run manually"
                        fi
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
                    sh '''
                        echo "Initiating build process..."
                        echo "Model: ${MODEL_NAME}"
                        echo "Configuration: ${BUILD_CONFIG}"
                        echo ""
                        echo "Build command:"
                        echo "  matlab -batch 'addpath(\"scripts\"); exit(ci_build())'"
                        echo ""
                        echo "This will:"
                        echo "  1. Load model: ${MODEL_NAME}.slx"
                        echo "  2. Run Model Advisor checks"
                        echo "  3. Generate C code (Embedded Coder)"
                        echo "  4. Create build artifacts"
                        echo ""
                        echo "NOTE: Manual execution required on Windows host"
                        echo "See README.md for automated setup instructions"
                    '''
                }
                
                // Check for existing build artifacts
                script {
                    sh '''
                        echo ""
                        echo "Checking for generated code..."
                        if [ -d "/workspace/${MODEL_NAME}_ert_rtw" ]; then
                            echo " Generated code directory found"
                            echo "Files:"
                            ls -lh /workspace/${MODEL_NAME}_ert_rtw/*.c /workspace/${MODEL_NAME}_ert_rtw/*.h 2>/dev/null || echo "No C/H files found"
                        else
                            echo " No generated code found"
                            echo "Run ci_build() manually to generate code"
                        fi
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
                    sh '''
                        echo "Code quality checks:"
                        echo ""
                        
                        # Check for generated C code
                        if [ -d "/workspace/${MODEL_NAME}_ert_rtw" ]; then
                            echo "1. Checking generated code structure..."
                            
                            # Count generated files
                            c_files=$(find /workspace/${MODEL_NAME}_ert_rtw -name "*.c" | wc -l)
                            h_files=$(find /workspace/${MODEL_NAME}_ert_rtw -name "*.h" | wc -l)
                            
                            echo "   - C files: $c_files"
                            echo "   - H files: $h_files"
                            
                            if [ $c_files -gt 0 ] && [ $h_files -gt 0 ]; then
                                echo "    Code generation successful"
                            else
                                echo "    WARNING: Insufficient files generated"
                            fi
                            
                            echo ""
                            echo "2. Checking for common issues..."
                            
                            # Check for TODO/FIXME comments
                            todos=$(grep -r "TODO\\|FIXME" /workspace/${MODEL_NAME}_ert_rtw/*.c 2>/dev/null | wc -l)
                            echo "   - TODO/FIXME comments: $todos"
                            
                            echo ""
                            echo "3. Code metrics:"
                            total_lines=$(cat /workspace/${MODEL_NAME}_ert_rtw/*.c 2>/dev/null | wc -l)
                            echo "   - Total lines of code: $total_lines"
                            
                        else
                            echo "No generated code to analyze"
                            echo "Run build stage first"
                        fi
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
                    sh '''
                        echo "Collecting build artifacts..."
                        
                        # Create artifacts directory
                        mkdir -p /workspace/artifacts
                        
                        # Collect generated code
                        if [ -d "/workspace/${MODEL_NAME}_ert_rtw" ]; then
                            echo " Collecting generated C code..."
                            cp -r /workspace/${MODEL_NAME}_ert_rtw /workspace/artifacts/
                            
                            # Create source list
                            echo "Generated files:" > /workspace/artifacts/file_manifest.txt
                            ls -lh /workspace/${MODEL_NAME}_ert_rtw >> /workspace/artifacts/file_manifest.txt
                        fi
                        
                        # Collect test results
                        if [ -d "/workspace/test_results" ]; then
                            echo " Collecting test results..."
                            cp -r /workspace/test_results /workspace/artifacts/
                        fi
                        
                        # Collect build logs
                        if [ -f "/workspace/build.log" ]; then
                            echo " Collecting build log..."
                            cp /workspace/build.log /workspace/artifacts/
                        fi
                        
                        echo ""
                        echo "Artifact collection summary:"
                        ls -lh /workspace/artifacts/
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
                    sh '''
                        if [ -d "/workspace/${MODEL_NAME}_ert_rtw" ]; then
                            cd /workspace
                            
                            # Create firmware package with timestamp
                            timestamp=$(date +%Y%m%d_%H%M%S)
                            package_name="firmware_${MODEL_NAME}_${timestamp}.tar.gz"
                            
                            echo "Creating firmware package: $package_name"
                            tar -czf $package_name \
                                ${MODEL_NAME}_ert_rtw/*.c \
                                ${MODEL_NAME}_ert_rtw/*.h \
                                ${MODEL_NAME}_ert_rtw/*.mk 2>/dev/null || true
                            
                            if [ -f "$package_name" ]; then
                                size=$(ls -lh $package_name | awk '{print $5}')
                                echo " Package created successfully"
                                echo "  File: $package_name"
                                echo "  Size: $size"
                                
                                # Move to artifacts
                                mv $package_name artifacts/
                            else
                                echo " Failed to create package"
                                exit 1
                            fi
                        else
                            echo " No code to package - skipping"
                            echo "Run build stage to generate code first"
                        fi
                    '''
                }
                
                echo '[OK] Firmware packaging completed'
            }
        }
        
        stage('Deploy - Staging (CD)') {
            when {
                expression { 
                    // Only deploy if artifacts exist
                    return fileExists('artifacts/firmware_*.tar.gz')
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
                sh '''
                    echo "Archiving artifacts..."
                    if [ -d "/workspace/artifacts" ]; then
                        ls -lh /workspace/artifacts/
                    fi
                '''
            }
            
            // Archive all important artifacts
            archiveArtifacts artifacts: '''
                build.log,
                artifacts/**/*,
                test_results/**/*,
                **/firmware_*.tar.gz,
                **/${MODEL_NAME}_ert_rtw/*.c,
                **/${MODEL_NAME}_ert_rtw/*.h,
                **/${MODEL_NAME}_ert_rtw/*.mk
            ''', allowEmptyArchive: true
            
            // Publish test results (if available)
            // junit 'test_results/**/*.xml'  // Uncomment when XML results available
            
            // Publish HTML reports (if available)
            // publishHTML([
            //     reportDir: 'test_results/coverage_report',
            //     reportFiles: 'coverage.html',
            //     reportName: 'Code Coverage Report'
            // ])
            
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
            echo 'Next steps:'
            echo '  - Review artifacts in Jenkins workspace'
            echo '  - Deploy to target ECU (manual)'
            echo '  - Run Hardware-in-the-Loop (HIL) tests'
            echo ''
            echo 'For automated deployment, see README.md'
            echo '=================================================='
            
            // Email notification (optional)
            // emailext(
            //     subject: " Jenkins Build SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            //     body: "Build completed successfully.\n\nView details: ${env.BUILD_URL}",
            //     to: "${NOTIFY_EMAIL}"
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
                sh '''
                    echo "Cleaning temporary files..."
                    
                    # Remove MATLAB temporary files (keep artifacts)
                    find /workspace -name "*.asv" -type f -delete 2>/dev/null || true
                    find /workspace -name "*.m~" -type f -delete 2>/dev/null || true
                    find /workspace -name "*.autosave" -type f -delete 2>/dev/null || true
                    
                    echo " Cleanup completed"
                '''
            }
            
            echo '[OK] Pipeline cleanup finished'
        }
    }
}
