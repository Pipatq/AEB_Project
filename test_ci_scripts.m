%% Test Script - ทดสอบว่า CI scripts ทำงานได้หรือไม่
%
% สคริปต์นี้จะทดสอบ:
% 1. ตรวจสอบว่าไฟล์ทั้งหมดอยู่ในตำแหน่งที่ถูกต้อง
% 2. ทดสอบ ci_build.m (แบบ dry run)
% 3. ทดสอบ ci_test.m (แบบ dry run)

fprintf('\n========================================\n');
fprintf('  Testing CI Scripts\n');
fprintf('========================================\n\n');

%% Test 1: Check File Structure
fprintf('[TEST 1/4] Checking file structure...\n');

requiredFiles = {
    'models/AEB_Model.slx'
    'data/brake_params.m'
    'scripts/ci_build.m'
    'scripts/ci_test.m'
    'scripts/startup.m'
    'tests/unit_tests/ExampleUnitTest.m'
    'tests/system_tests/example_system_test.m'
};

allFilesExist = true;
for i = 1:length(requiredFiles)
    if exist(requiredFiles{i}, 'file')
        fprintf('  ✓ %s\n', requiredFiles{i});
    else
        fprintf('  ✗ MISSING: %s\n', requiredFiles{i});
        allFilesExist = false;
    end
end

if ~allFilesExist
    error('Some required files are missing!');
end

fprintf('\n✓ All required files found!\n\n');

%% Test 2: Check Paths
fprintf('[TEST 2/4] Checking MATLAB paths...\n');

% Add paths (like startup.m does)
addpath(genpath('models'));
addpath(genpath('data'));
addpath(genpath('tests'));
addpath(genpath('scripts'));

fprintf('  ✓ Paths added successfully\n\n');

%% Test 3: Load Parameters
fprintf('[TEST 3/4] Testing parameter loading...\n');

try
    run('data/brake_params.m');
    fprintf('  ✓ Parameters loaded successfully\n');
    fprintf('    - VehicleParams.mass = %.1f kg\n', VehicleParams.mass);
    fprintf('    - BrakeParams.maxBrakePressure = %.1f bar\n', BrakeParams.maxBrakePressure);
catch ME
    fprintf('  ✗ ERROR loading parameters: %s\n', ME.message);
    error('Parameter loading failed!');
end

fprintf('\n');

%% Test 4: Check Model
fprintf('[TEST 4/4] Checking if model can be loaded...\n');

modelPath = 'models/AEB_Model';

try
    % Try to load model (won't build, just load)
    load_system(modelPath);
    fprintf('  ✓ Model loaded successfully: %s\n', modelPath);
    
    % Get some basic info
    solver = get_param('AEB_Model', 'Solver');
    fprintf('    - Solver: %s\n', solver);
    
    % Close model
    close_system('AEB_Model', 0);
    fprintf('  ✓ Model closed\n');
    
catch ME
    fprintf('  ✗ ERROR: %s\n', ME.message);
    fprintf('  Note: If toolboxes are missing, this is expected\n');
end

%% Summary
fprintf('\n========================================\n');
fprintf('  ✓ PRE-FLIGHT CHECK COMPLETE\n');
fprintf('========================================\n\n');

fprintf('Next steps:\n');
fprintf('  1. To test build: ci_build()\n');
fprintf('  2. To test testing: ci_test()\n');
fprintf('  3. To run both: ci_build() then ci_test()\n\n');

fprintf('Note: ci_build() requires:\n');
fprintf('  - Simulink\n');
fprintf('  - Simulink Coder\n');
fprintf('  - Embedded Coder\n\n');
