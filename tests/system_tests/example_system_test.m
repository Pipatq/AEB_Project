%EXAMPLE_SYSTEM_TEST Example system-level test for AEB
%
% This script tests the complete AEB system behavior
% Copy and modify this to create your own system tests

fprintf('Running System Test: Emergency Braking Scenario\n');
fprintf('================================================\n\n');

%% Load Parameters
run('data/brake_params.m');

%% Test Configuration
initialSpeed = 60;      % km/h
obstacleDistance = 40;  % meters
obstacleSpeed = 0;      % km/h (stationary)

fprintf('Test Scenario:\n');
fprintf('  Initial Speed: %.1f km/h\n', initialSpeed);
fprintf('  Obstacle Distance: %.1f m\n', obstacleDistance);
fprintf('  Obstacle Speed: %.1f km/h\n\n', obstacleSpeed);

%% Run Simulation
% NOTE: This requires the actual AEB_Model.slx to exist
% For now, we'll create a simplified test

% Convert to m/s
initialSpeed_ms = initialSpeed / 3.6;
obstacleSpeed_ms = obstacleSpeed / 3.6;

% Calculate time to collision
relativeSpeed = initialSpeed_ms - obstacleSpeed_ms;
timeToCollision = obstacleDistance / relativeSpeed;

fprintf('Calculated TTC: %.2f seconds\n', timeToCollision);

%% Test Assertions
testPassed = true;

% Test 1: TTC should trigger AEB
if timeToCollision < AEBParams.timeToCollision
    fprintf('✓ Test 1 PASSED: AEB should activate (TTC < threshold)\n');
else
    fprintf('✗ Test 1 FAILED: AEB should NOT activate\n');
    testPassed = false;
end

% Test 2: Sufficient distance to stop
brakingDistance = (initialSpeed_ms^2) / (2 * BrakeParams.maxDeceleration);
fprintf('Required braking distance: %.2f m\n', brakingDistance);

if brakingDistance < obstacleDistance
    fprintf('✓ Test 2 PASSED: Sufficient distance to stop\n');
else
    fprintf('✗ Test 2 FAILED: Insufficient braking distance!\n');
    testPassed = false;
end

%% Test Result
fprintf('\n================================================\n');
if testPassed
    fprintf('SYSTEM TEST PASSED ✓\n');
else
    fprintf('SYSTEM TEST FAILED ✗\n');
    error('System test failed - check parameters');
end
fprintf('================================================\n');
