%STARTUP Project initialization script
%
% This script runs automatically when opening AEB_Project.prj
% It sets up the environment, paths, and configurations.

fprintf('\n========================================\n');
fprintf('  AEB Project - Initializing...\n');
fprintf('========================================\n\n');

%% Add Project Paths
fprintf('Adding project paths...\n');
addpath(genpath('models'));
addpath(genpath('data'));
addpath(genpath('tests'));
addpath(genpath('scripts'));
fprintf('  ✓ Paths configured\n\n');

%% Load Default Parameters
fprintf('Loading default parameters...\n');
if exist('data/brake_params.m', 'file')
    run('data/brake_params.m');
    fprintf('  ✓ Parameters loaded from brake_params.m\n');
else
    fprintf('  ! brake_params.m not found - create it in data/ folder\n');
end

%% Display Project Info
fprintf('\n========================================\n');
fprintf('  Project Ready!\n');
fprintf('========================================\n');
fprintf('Available commands:\n');
fprintf('  - ci_build()  : Build and generate code\n');
fprintf('  - ci_test()   : Run all tests\n');
fprintf('  - help <function> : Get help on any function\n');
fprintf('\n');
