%BRAKE_PARAMS Parameter definitions for AEB System
%
% This file contains all configurable parameters for the AEB model.
% Modify these values to tune system behavior.

fprintf('Loading AEB System Parameters...\n');

%% Vehicle Parameters
VehicleParams = struct();
VehicleParams.mass = 1500;              % Vehicle mass [kg]
VehicleParams.frontalArea = 2.5;        % Frontal area [m^2]
VehicleParams.dragCoeff = 0.3;          % Aerodynamic drag coefficient
VehicleParams.wheelRadius = 0.3;        % Wheel radius [m]

%% Brake System Parameters
BrakeParams = struct();
BrakeParams.maxBrakePressure = 100;     % Maximum brake pressure [bar]
BrakeParams.responseTime = 0.2;         % Brake system response time [s]
BrakeParams.brakingEfficiency = 0.85;   % Braking efficiency factor
BrakeParams.maxDeceleration = 9.81;     % Max deceleration [m/s^2] (~1g)

%% AEB Controller Parameters
AEBParams = struct();
AEBParams.sensorRange = 100;            % Radar range [m]
AEBParams.minActivationSpeed = 30;      % Minimum speed for AEB [km/h]
AEBParams.maxActivationSpeed = 120;     % Maximum speed for AEB [km/h]
AEBParams.timeToCollision = 2.0;        % TTC threshold [s]
AEBParams.warningTime = 3.0;            % Warning lead time [s]

%% Simulation Parameters
SimParams = struct();
SimParams.sampleTime = 0.01;            % Simulation time step [s]
SimParams.stopTime = 10;                % Default simulation time [s]
SimParams.solver = 'ode4';              % Fixed-step Runge-Kutta solver

%% Test Scenarios
TestScenarios = struct();
TestScenarios.scenario1.name = 'Stationary Obstacle';
TestScenarios.scenario1.initialSpeed = 50;      % [km/h]
TestScenarios.scenario1.obstacleDistance = 40;  % [m]
TestScenarios.scenario1.obstacleSpeed = 0;      % [km/h]

TestScenarios.scenario2.name = 'Slow Moving Obstacle';
TestScenarios.scenario2.initialSpeed = 60;      % [km/h]
TestScenarios.scenario2.obstacleDistance = 50;  % [m]
TestScenarios.scenario2.obstacleSpeed = 20;     % [km/h]

fprintf('  ✓ Parameters loaded successfully\n');
