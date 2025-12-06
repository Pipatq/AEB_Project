function exitCode = ci_test()
    %CI_TEST Automated test script for Jenkins CI/CD Pipeline
    %
    % This script performs comprehensive testing:
    %   1. Unit tests (individual components)
    %   2. Integration tests (combined systems)
    %   3. MIL (Model-in-the-Loop) tests
    %   4. Code coverage analysis
    %   5. Test report generation
    %
    % Returns:
    %   exitCode - 0 for success, non-zero for failure
    %
    % Usage (from Jenkins):
    %   matlab -batch "addpath('scripts'); exit(ci_test())"
    
    %% Initialize
    fprintf('\n========================================\n');
    fprintf('  CI TEST SCRIPT - AEB Project\n');
    fprintf('========================================\n\n');
    
    exitCode = 0;
    testLogFile = 'test_results/test.log';
    
    % Create test results directory
    if ~exist('test_results', 'dir')
        mkdir('test_results');
    end
    
    diary(testLogFile);
    diary on;
    
    try
        %% Step 1: Environment Setup
        fprintf('[STEP 1/4] Setting up test environment...\n');
        
        % Add project paths
        addpath(genpath('models'));
        addpath(genpath('data'));
        addpath(genpath('tests'));
        addpath(genpath('scripts'));
        
        % Load parameters
        if exist('data/brake_params.m', 'file')
            run('data/brake_params.m');
            fprintf('  - Test parameters loaded\n');
        end
        
        %% Step 2: Run Unit Tests
        fprintf('\n[STEP 2/4] Running unit tests...\n');
        
        unitTestDir = 'tests/unit_tests';
        if exist(unitTestDir, 'dir')
            unitTestSuite = matlab.unittest.TestSuite.fromFolder(unitTestDir);
            
            if ~isempty(unitTestSuite)
                runner = matlab.unittest.TestRunner.withTextOutput;
                
                % Add JUnit XML plugin for Jenkins integration
                import matlab.unittest.plugins.XMLPlugin
                xmlFile = 'test_results/junit_results.xml';
                runner.addPlugin(XMLPlugin.producingJUnitFormat(xmlFile));
                fprintf('  - JUnit XML report will be saved to: %s\n', xmlFile);
                
                % Add coverage plugin with HTML report
                coverageReport = matlab.unittest.plugins.codecoverage.CoverageReport(...
                    'test_results/coverage_report', 'MainFile', 'coverage.html');
                plugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder(...
                    'models', 'Producing', coverageReport);
                runner.addPlugin(plugin);
                fprintf('  - Coverage report will be saved to: test_results/coverage_report/\n');
                
                % Run tests
                unitResults = runner.run(unitTestSuite);
                
                % Display results
                fprintf('  - Total Tests: %d\n', length(unitResults));
                fprintf('  - Passed: %d\n', sum([unitResults.Passed]));
                fprintf('  - Failed: %d\n', sum([unitResults.Failed]));
                
                if any([unitResults.Failed])
                    fprintf('  - WARNING: Some unit tests failed!\n');
                    exitCode = 1;
                end
            else
                fprintf('  - No unit tests found (create tests in %s)\n', unitTestDir);
            end
        else
            fprintf('  - Unit test directory not found (will be created)\n');
            mkdir(unitTestDir);
        end
        
        %% Step 3: Run System Tests
        fprintf('\n[STEP 3/4] Running system/integration tests...\n');
        
        systemTestDir = 'tests/system_tests';
        if exist(systemTestDir, 'dir')
            systemTestFiles = dir(fullfile(systemTestDir, '*.m'));
            
            if ~isempty(systemTestFiles)
                fprintf('  - Found %d system test files\n', length(systemTestFiles));
                
                % Run each test file
                for i = 1:length(systemTestFiles)
                    [~, testName, ~] = fileparts(systemTestFiles(i).name);
                    fprintf('    Running: %s...\n', testName);
                    
                    try
                        run(fullfile(systemTestDir, systemTestFiles(i).name));
                        fprintf('      [PASS]\n');
                    catch ME
                        fprintf('      [FAIL]: %s\n', ME.message);
                        exitCode = 1;
                    end
                end
            else
                fprintf('  - No system tests found (create tests in %s)\n', systemTestDir);
            end
        else
            fprintf('  - System test directory not found (will be created)\n');
            mkdir(systemTestDir);
        end
        
        %% Step 4: MIL Testing (Model-in-the-Loop)
        fprintf('\n[STEP 4/4] Running MIL tests...\n');
        
        modelName = 'AEB_Model';
        modelPath = 'models/AEB_Model';
        
        if exist([modelPath '.slx'], 'file')
            load_system(modelPath);
            fprintf('  - Model loaded: %s\n', modelName);
            
            % Run model simulation as basic MIL test
            fprintf('  - Running model simulation...\n');
            simOut = sim(modelName, 'SaveOutput', 'on', 'ReturnWorkspaceOutputs', 'on');
            fprintf('  - Simulation completed (%.2f sec simulated)\n', simOut.tout(end));
            
            % Basic validation - check for NaN/Inf in outputs
            % This ensures numerical stability of the simulation
            hasError = false;
            if any(isnan(simOut.yout{1}.Values.Data(:))) || any(isinf(simOut.yout{1}.Values.Data(:)))
                fprintf('  - [ERROR] Output contains NaN or Inf values!\n');
                hasError = true;
                exitCode = 1;
            else
                fprintf('  - [OK] Output validation passed\n');
            end
            
            % Save simulation results
            save('test_results/mil_simulation.mat', 'simOut');
            fprintf('  - Results saved to test_results/mil_simulation.mat\n');
            
            close_system(modelName, 0);
        else
            fprintf('  - Model not found, skipping MIL tests\n');
        end
        
        %% Generate Test Report
        fprintf('\n========================================\n');
        if exitCode == 0
            fprintf('  ALL TESTS PASSED!\n');
        else
            fprintf('  TESTS FAILED - CHECK LOGS\n');
        end
        fprintf('========================================\n\n');
        
    catch ME
        %% Error Handling
        fprintf('\n========================================\n');
        fprintf('  TEST EXECUTION FAILED!\n');
        fprintf('========================================\n');
        fprintf('Error: %s\n', ME.message);
        if ~isempty(ME.stack)
            fprintf('Location: %s (line %d)\n', ME.stack(1).file, ME.stack(1).line);
        end
        
        exitCode = 1;
    end
    
    %% Cleanup
    diary off;
    fprintf('\nTest log saved to: %s\n', testLogFile);
    
end
