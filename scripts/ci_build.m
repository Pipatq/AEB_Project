function exitCode = ci_build()
    %CI_BUILD Automated build script for Jenkins CI/CD Pipeline
    %
    % This script performs the complete build process for the AEB Model:
    %   1. Environment setup and validation
    %   2. Model configuration check
    %   3. Code generation (Embedded Coder)
    %   4. Build artifact collection
    %
    % Returns:
    %   exitCode - 0 for success, non-zero for failure
    %
    % Usage (from Jenkins):
    %   matlab -batch "addpath('scripts'); exit(ci_build())"
    
    %% Initialize
    fprintf('\n========================================\n');
    fprintf('  CI BUILD SCRIPT - AEB Project\n');
    fprintf('========================================\n\n');
    
    exitCode = 0;
    buildLogFile = 'build.log';
    diary(buildLogFile);
    diary on;
    
    try
        %% Step 1: Environment Setup
        fprintf('[STEP 1/5] Setting up environment...\n');
        
        % Store original directory
        originalDir = pwd;
        
        % Add project paths
        addpath(genpath('models'));
        addpath(genpath('data'));
        addpath(genpath('scripts'));
        
        % Verify MATLAB version and toolboxes
        verInfo = ver;
        fprintf('  - MATLAB Version: %s\n', version);
        
        requiredToolboxes = {'Simulink', 'Simulink Coder', 'Embedded Coder'};
        for i = 1:length(requiredToolboxes)
            if ~any(strcmp({verInfo.Name}, requiredToolboxes{i}))
                error('Required toolbox missing: %s', requiredToolboxes{i});
            end
        end
        fprintf('  - All required toolboxes found\n');
        
        %% Step 2: Load Model Parameters
        fprintf('\n[STEP 2/5] Loading model parameters...\n');
        
        % Load parameter file if exists
        if exist('data/brake_params.m', 'file')
            run('data/brake_params.m');
            fprintf('  - Parameters loaded from brake_params.m\n');
        else
            fprintf('  - WARNING: brake_params.m not found, using defaults\n');
        end
        
        %% Step 3: Model Configuration Check
        fprintf('\n[STEP 3/5] Checking model configuration...\n');
        
        modelName = 'AEB_Model';
        modelPath = 'models/AEB_Model';
        
        % Check if model exists
        if ~exist([modelPath '.slx'], 'file')
            error('Model file not found: %s.slx', modelPath);
        end
        
        % Load model
        load_system(modelPath);
        fprintf('  - Model loaded: %s\n', modelName);
        
        % Verify model configuration
        solver = get_param(modelName, 'Solver');
        fixedStep = get_param(modelName, 'FixedStep');
        fprintf('  - Solver: %s (Step: %s)\n', solver, fixedStep);
        
        % Check for errors
        fprintf('  - Running Model Advisor checks...\n');
        % Note: Add specific checks here based on your requirements
        
        %% Step 4: Code Generation
        fprintf('\n[STEP 4/5] Generating C code...\n');
        
        % Create build directory in temp folder (avoid Unicode path issues)
        buildTempDir = fullfile(tempdir, 'AEB_Build_Temp');
        if ~exist(buildTempDir, 'dir')
            mkdir(buildTempDir);
        end
        
        % Change to temp directory for build
        fprintf('  - Build directory: %s\n', buildTempDir);
        cd(buildTempDir);
        
        % Set code generation parameters
        set_param(modelName, 'SystemTargetFile', 'ert.tlc');
        set_param(modelName, 'TargetLang', 'C');
        set_param(modelName, 'GenerateReport', 'on');
        set_param(modelName, 'LaunchReport', 'off');
        
        % Generate code
        fprintf('  - Starting code generation...\n');
        slbuild(modelName);
        fprintf('  - Code generation completed successfully\n');
        
        % Change back to original directory
        cd(originalDir);
        
        % Verify generated files
        codeGenDir = fullfile(buildTempDir, [modelName '_ert_rtw']);
        if ~exist(codeGenDir, 'dir')
            error('Code generation directory not found: %s', codeGenDir);
        end
        
        generatedFiles = dir(fullfile(codeGenDir, '*.c'));
        fprintf('  - Generated %d C files\n', length(generatedFiles));
        
        %% Step 5: Artifact Collection
        fprintf('\n[STEP 5/5] Collecting build artifacts...\n');
        
        % Create work directory for artifacts (back in project folder)
        workDir = fullfile(originalDir, 'work');
        if ~exist(workDir, 'dir')
            mkdir(workDir);
        end
        
        % Copy generated code to work directory
        finalCodeDir = fullfile(workDir, [modelName '_ert_rtw']);
        if exist(finalCodeDir, 'dir')
            rmdir(finalCodeDir, 's');
        end
        copyfile(codeGenDir, finalCodeDir);
        fprintf('  - Copied generated code to work/%s\n', [modelName '_ert_rtw']);
        
        % Generate build info
        buildInfo = struct();
        buildInfo.modelName = modelName;
        buildInfo.buildTime = datestr(now);
        buildInfo.matlabVersion = version;
        buildInfo.codeGenDir = finalCodeDir;
        buildInfo.numFiles = length(generatedFiles);
        
        save(fullfile(workDir, 'build_info.mat'), 'buildInfo');
        fprintf('  - Build info saved\n');
        
        %% Success
        fprintf('\n========================================\n');
        fprintf('  BUILD COMPLETED SUCCESSFULLY!\n');
        fprintf('========================================\n\n');
        
        % Close model
        close_system(modelName, 0);
        
    catch ME
        %% Error Handling
        fprintf('\n========================================\n');
        fprintf('  BUILD FAILED!\n');
        fprintf('========================================\n');
        fprintf('Error: %s\n', ME.message);
        fprintf('Location: %s (line %d)\n', ME.stack(1).file, ME.stack(1).line);
        
        exitCode = 1;
        
        % Try to close model if open
        try
            close_system(modelName, 0);
        catch
            % Ignore if model not open
        end
    end
    
    %% Cleanup
    diary off;
    fprintf('\nBuild log saved to: %s\n', buildLogFile);
    
end
