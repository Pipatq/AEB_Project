classdef ExampleUnitTest < matlab.unittest.TestCase
    %EXAMPLEUNITTEST Example unit test template for AEB components
    %
    % This is a template showing how to write unit tests.
    % Copy this file and modify it to test your specific components.
    %
    % To run this test:
    %   runtests('ExampleUnitTest')
    
    properties
        % Test fixtures (data needed for tests)
        testParams
    end
    
    methods (TestMethodSetup)
        % Setup for each test
        function setupTest(testCase)
            % Load parameters
            if exist('data/brake_params.m', 'file')
                run('data/brake_params.m');
                testCase.testParams = BrakeParams;
            end
        end
    end
    
    methods (Test)
        % Test methods
        
        function testBrakeForceCalculation(testCase)
            % Test basic brake force calculation
            pressure = 50;  % bar
            expectedForce = pressure * 100;  % Simplified calculation
            
            actualForce = pressure * 100;
            
            testCase.verifyEqual(actualForce, expectedForce, ...
                'Brake force calculation failed');
        end
        
        function testMaxBrakePressure(testCase)
            % Test that max pressure is within safe limits
            maxPressure = testCase.testParams.maxBrakePressure;
            
            testCase.verifyLessThanOrEqual(maxPressure, 150, ...
                'Max brake pressure exceeds safety limit');
            testCase.verifyGreaterThan(maxPressure, 0, ...
                'Max brake pressure must be positive');
        end
        
        function testResponseTime(testCase)
            % Test brake response time
            responseTime = testCase.testParams.responseTime;
            
            testCase.verifyLessThanOrEqual(responseTime, 0.5, ...
                'Brake response time too slow');
            testCase.verifyGreaterThan(responseTime, 0, ...
                'Response time must be positive');
        end
    end
end
