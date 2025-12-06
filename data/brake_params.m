%BRAKE_PARAMS Parameter definitions for AEB System
%
% This file defines all configurable parameters for the AEB model including:
%   - Vehicle physical characteristics (mass, aerodynamics)
%   - Brake system specifications (pressure, response time)
%   - AEB controller thresholds (TTC, activation speeds)
%   - Simulation configuration (solver, time steps)
%   - Test scenario definitions
%
% Modify these values to tune system behavior or test different scenarios.
% All parameters are loaded into workspace as structs for easy access.

fprintf('Loading AEB System Parameters...\n');

%% Vehicle Parameters
% Physical characteristics of the target vehicle
% These affect braking dynamics and stopping distance calculations
VehicleParams = struct();
VehicleParams.mass = 1500;              % Total vehicle mass including passengers [kg]
VehicleParams.frontalArea = 2.5;        % Cross-sectional area for drag calculation [m^2]
VehicleParams.dragCoeff = 0.3;          % Aerodynamic drag coefficient (typical sedan)
VehicleParams.wheelRadius = 0.3;        % Effective wheel radius for torque calculations [m]

%% Brake System Parameters
% Hydraulic brake system specifications
% These define the physical limits and response characteristics
BrakeParams = struct();
BrakeParams.maxBrakePressure = 100;     % Maximum hydraulic pressure limit [bar]
BrakeParams.responseTime = 0.2;         % Actuator delay from command to pressure buildup [s]
BrakeParams.brakingEfficiency = 0.85;   % Friction and heat loss factor (0-1)
BrakeParams.maxDeceleration = 9.81;     % Maximum achievable deceleration [m/s^2] (approximately 1g)

%% AEB Controller Parameters
% Automatic Emergency Braking controller decision thresholds
% Critical parameters for collision avoidance performance
AEBParams = struct();
AEBParams.sensorRange = 100;            % Maximum detection range of radar/camera [m]
AEBParams.minActivationSpeed = 30;      % AEB disabled below this speed [km/h]
AEBParams.maxActivationSpeed = 120;     % AEB disabled above this speed [km/h]
AEBParams.timeToCollision = 2.0;        % TTC threshold for emergency braking [s]
AEBParams.warningTime = 3.0;            % TTC threshold for driver warning only [s]

%% Simulation Parameters
% Numerical solver configuration for Simulink simulation
% Fixed-step solver ensures deterministic execution for code generation
SimParams = struct();
SimParams.sampleTime = 0.01;            % Discrete time step (100 Hz control rate) [s]
SimParams.stopTime = 10;                % Default simulation duration [s]
SimParams.solver = 'ode4';              % Fixed-step 4th order Runge-Kutta solver

%% Test Scenarios
% Predefined test scenarios for validation and verification
% Each scenario represents a typical AEB use case
TestScenarios = struct();

% Scenario 1: Vehicle approaching stationary obstacle
TestScenarios.scenario1.name = 'Stationary Obstacle';
TestScenarios.scenario1.initialSpeed = 50;      % Ego vehicle speed [km/h]
TestScenarios.scenario1.obstacleDistance = 40;  % Initial distance to obstacle [m]
TestScenarios.scenario1.obstacleSpeed = 0;      % Obstacle velocity [km/h]

% Scenario 2: Vehicle approaching slower moving vehicle
TestScenarios.scenario2.name = 'Slow Moving Obstacle';
TestScenarios.scenario2.initialSpeed = 60;      % Ego vehicle speed [km/h]
TestScenarios.scenario2.obstacleDistance = 50;  % Initial distance to obstacle [m]
TestScenarios.scenario2.obstacleSpeed = 20;     % Obstacle velocity [km/h]

fprintf('  [OK] Parameters loaded successfully\n');
