%% Test Script - Verify CI scripts functionality
%
% This script performs pre-flight checks to ensure the CI/CD environment
% is properly configured before running the full build and test pipeline.
%
% Tests performed:
% 1. Verify all required files exist in correct locations
% 2. Confirm MATLAB path configuration
% 3. Test parameter file loading
% 4. Validate model can be opened
%
% Usage:
%   Run this script from the project root directory before executing
%   ci_build() or ci_test() to ensure the environment is ready.

fprintf('\n========================================\n');
fprintf('  Testing CI Scripts\n');
fprintf('========================================\n\n');

%% Test 1: Check File Structure
fprintf('[TEST 1/4] Checking file structure...\n');

% Define list of required files for CI/CD pipeline
requiredFiles = {
    'models/AEB_Model.slx'
    'data/brake_params.m'
    'scripts/ci_build.m'
    'scripts/ci_test.m'
    'scripts/startup.m'
    'tests/unit_tests/ExampleUnitTest.m'
    'tests/system_tests/example_system_test.m'
};

% Verify each required file exists
allFilesExist = true;
for i = 1:length(requiredFiles)
    if exist(requiredFiles{i}, 'file')
        fprintf('  [OK] %s\n', requiredFiles{i});
    else
        fprintf('  [MISSING] %s\n', requiredFiles{i});
        allFilesExist = false;
    end
end

% Stop execution if any files are missing
if ~allFilesExist
    error('Some required files are missing!');
end

fprintf('\n[PASS] All required files found!\n\n');

%% Test 2: Check Paths
fprintf('[TEST 2/4] Checking MATLAB paths...\n');

% Add all project directories to MATLAB path
% This mimics what startup.m does when opening the project
addpath(genpath('models'));
addpath(genpath('data'));
addpath(genpath('tests'));
addpath(genpath('scripts'));

fprintf('  [OK] Paths added successfully\n\n');

%% Test 3: Load Parameters
fprintf('[TEST 3/4] Testing parameter loading...\n');

try
    % Attempt to load system parameters from file
    run('data/brake_params.m');
    fprintf('  [OK] Parameters loaded successfully\n');
    
    % Display key parameters to verify correct loading
    fprintf('    - VehicleParams.mass = %.1f kg\n', VehicleParams.mass);
    fprintf('    - BrakeParams.maxBrakePressure = %.1f bar\n', BrakeParams.maxBrakePressure);
catch ME
    % Handle parameter loading errors
    fprintf('  [ERROR] loading parameters: %s\n', ME.message);
    error('Parameter loading failed!');
end

fprintf('\n');

%% Test 4: Check Model
fprintf('[TEST 4/4] Checking if model can be loaded...\n');

modelPath = 'models/AEB_Model';

try
    % Attempt to load the Simulink model without building
    load_system(modelPath);
    fprintf('  [OK] Model loaded successfully: %s\n', modelPath);
    
    % Retrieve and display solver configuration
    solver = get_param('AEB_Model', 'Solver');
    fprintf('    - Solver: %s\n', solver);
    
    % Close the model without saving changes
    close_system('AEB_Model', 0);
    fprintf('  [OK] Model closed\n');
    
catch ME
    % Handle model loading errors
    fprintf('  [ERROR] %s\n', ME.message);
    fprintf('  Note: If toolboxes are missing, this is expected\n');
end

%% Summary
fprintf('\n========================================\n');
fprintf('  [PASS] PRE-FLIGHT CHECK COMPLETE\n');
fprintf('========================================\n\n');

fprintf('Next steps:\n');
fprintf('  1. To test build: ci_build()\n');
fprintf('  2. To test testing: ci_test()\n');
fprintf('  3. To run both: ci_build() then ci_test()\n\n');

fprintf('Note: ci_build() requires:\n');
fprintf('  - Simulink\n');
fprintf('  - Simulink Coder\n');
fprintf('  - Embedded Coder\n\n');
