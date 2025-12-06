%STARTUP Project initialization script
%
% This script runs automatically when opening AEB_Project.prj
% It configures the MATLAB environment for the AEB project by:
%   - Adding all project directories to the MATLAB path
%   - Loading default system parameters
%   - Displaying available commands for the user
%
% This ensures consistent environment setup for all developers
% and CI/CD automation.

fprintf('\n========================================\n');
fprintf('  AEB Project - Initializing...\n');
fprintf('========================================\n\n');

%% Add Project Paths
% Add all project subdirectories to MATLAB path to ensure
% models, data files, tests, and scripts are accessible
fprintf('Adding project paths...\n');
addpath(genpath('models'));      % Simulink model files
addpath(genpath('data'));        % Parameter and configuration files
addpath(genpath('tests'));       % Unit and system test files
addpath(genpath('scripts'));     % Build and automation scripts
fprintf('  [OK] Paths configured\n\n');

%% Load Default Parameters
% Attempt to load system parameters from the data directory
% These parameters define vehicle, brake, and AEB controller settings
fprintf('Loading default parameters...\n');
if exist('data/brake_params.m', 'file')
    run('data/brake_params.m');
    fprintf('  [OK] Parameters loaded from brake_params.m\n');
else
    fprintf('  [WARNING] brake_params.m not found - create it in data/ folder\n');
end

%% Display Project Info
% Show user the available commands for build, test, and help
fprintf('\n========================================\n');
fprintf('  Project Ready!\n');
fprintf('========================================\n');
fprintf('Available commands:\n');
fprintf('  - ci_build()  : Build model and generate C code\n');
fprintf('  - ci_test()   : Run all unit and system tests\n');
fprintf('  - help <function> : Get detailed help on any function\n');
fprintf('\n');
