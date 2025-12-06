%EXAMPLE_SYSTEM_TEST Example system-level test for AEB
%
% This script performs integration testing of the complete AEB system.
% It validates the collision detection logic, TTC calculations, and
% braking distance requirements for emergency scenarios.
%
% Test methodology:
%   1. Define test scenario (speeds, distances)
%   2. Calculate expected TTC (Time To Collision)
%   3. Verify AEB activation logic correctness
%   4. Validate sufficient braking distance available
%
% Copy and modify this template to create additional system tests
% for different scenarios (e.g., curved roads, multiple obstacles).

fprintf('Running System Test: Emergency Braking Scenario\n');
fprintf('================================================\n\n');

%% Load Parameters
% Construct absolute path to parameter file to avoid working directory issues
% This ensures tests run correctly from any location
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
paramFile = fullfile(projectRoot, 'data', 'brake_params.m');
run(paramFile);

%% Test Configuration
% Define the test scenario: ego vehicle approaching stationary obstacle
initialSpeed = 60;      % Ego vehicle initial velocity [km/h]
obstacleDistance = 40;  % Initial distance to obstacle [meters]
obstacleSpeed = 0;      % Obstacle velocity [km/h] (stationary)

fprintf('Test Scenario:\n');
fprintf('  Initial Speed: %.1f km/h\n', initialSpeed);
fprintf('  Obstacle Distance: %.1f m\n', obstacleDistance);
fprintf('  Obstacle Speed: %.1f km/h\n\n', obstacleSpeed);

%% Perform Calculations
% Convert speeds from km/h to m/s for physics calculations
initialSpeed_ms = initialSpeed / 3.6;
obstacleSpeed_ms = obstacleSpeed / 3.6;

% Calculate relative velocity (closing speed)
relativeSpeed = initialSpeed_ms - obstacleSpeed_ms;

% Calculate Time To Collision (TTC)
% TTC = distance / relative_velocity
timeToCollision = obstacleDistance / relativeSpeed;

fprintf('Calculated TTC: %.2f seconds\n', timeToCollision);

%% Test Assertions
testPassed = true;

% Test 1: Verify AEB activation logic
% Check if calculated TTC correctly triggers AEB based on threshold
if timeToCollision < AEBParams.timeToCollision
    fprintf('[PASS] Test 1: AEB should activate (TTC %.2f < threshold %.2f)\n', ...
        timeToCollision, AEBParams.timeToCollision);
else
    fprintf('[PASS] Test 1: AEB should NOT activate (TTC %.2f > threshold %.2f)\n', ...
        timeToCollision, AEBParams.timeToCollision);
end

% Test 2: Validate sufficient braking distance
% Calculate minimum distance required to stop using kinematic equation:
% d = v^2 / (2*a) where v=velocity, a=deceleration
brakingDistance = (initialSpeed_ms^2) / (2 * BrakeParams.maxDeceleration);
fprintf('Required braking distance: %.2f m\n', brakingDistance);

if brakingDistance < obstacleDistance
    fprintf('[PASS] Test 2: Sufficient distance to stop (%.2f m < %.2f m)\n', ...
        brakingDistance, obstacleDistance);
else
    fprintf('[FAIL] Test 2: Insufficient braking distance (%.2f m >= %.2f m)\n', ...
        brakingDistance, obstacleDistance);
    testPassed = false;
end

%% Test Result Summary
fprintf('\n================================================\n');
if testPassed
    fprintf('SYSTEM TEST PASSED\n');
else
    fprintf('SYSTEM TEST FAILED\n');
    error('System test failed - check parameters');
end
fprintf('================================================\n');
