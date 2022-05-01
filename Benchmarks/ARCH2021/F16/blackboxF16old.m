function [T, XT, YT, LT, CLG, Guards] = blackboxF16old(X0,~,~,~)
% Blackbox model to run the F16 aircraft using Staliro

% (C) 2019, Shakiba Yaghoubi, Arizona State University

global analysisOn, %#ok<NUSED>
global printOn, 
global plotOn,
global InitAlt,

%added
model_err = false;
analysisOn = false;
printOn = false;
plotOn = false;
backCalculateBestSamp = false;

LT = [];
CLG = [];
Guards = [];
T = [];  %#ok<NASGU>

powg = 9;                   % Power
% Default alpha & beta
alphag = deg2rad(2.1215);   % Trim Angle of Attack (rad)
betag = 0;                  % Side slip angle (rad)

%removed
% Initial Attitude (for simpleGCAS)
%altg = InitAlt;        %4040 is falsifiable but not easily
%Vtg = 540;             % Pass at Vtg = 540;    Fail at Vtg = %550;
%phig = X0(1);          % Roll angle from wings level (rad)
%thetag = X0(2);        % Pitch angle from nose level (rad)
%psig = X0(3);          % Yaw angle from North (rad)
%t_vec = 0:0.01:15;     % Time vector for simulation output
%added
% Initial Attitude (for simpleGCAS)
altg   = 4040;
Vtg    = 540;
phig   = (pi/2)*0.5;
thetag = -(pi/2)*0.8;
psig   = -(pi/4);
t_vec = 0:0.01:15;

% Set Flight & Ctrl Limits (for pass-fail conditions)
[flightLimits,ctrlLimits,autopilot] = getDefaultSettings();
ctrlLimits.ThrottleMax = 0.7;   % Limit to Mil power (no afterburner)
autopilot.simpleGCAS = true;    % Run GCAS simulation

% Build Initial Condition Vectors
initialState = [Vtg alphag betag phig thetag psig 0 0 0 0 0 altg powg];
orient = 4;             % Orientation for trim

%added
% Set Flight & Ctrl Limits (for pass-fail conditions)
[flightLimits,ctrlLimits,autopilot] = getDefaultSettings();
ctrlLimits.ThrottleMax = 0.7;   % Limit to Mil power (no afterburner)
autopilot.simpleGCAS = true;    % Run GCAS simulation

% Build Initial Condition Vectors
initialState = [Vtg alphag betag phig thetag psig 0 0 0 0 0 altg powg];
orient = 4;             % Orientation for trim


% Select Desired F-16 Plant
% Table Lookup
[output, passFail] = RunF16Sim(initialState, t_vec, orient, 'stevens',...
    flightLimits, ctrlLimits, autopilot, printOn, plotOn);

% Polynomial
% [output, passFail] = RunF16Sim(initialState, t_vec, orient, 'morelli',...
%     flightLimits, ctrlLimits, autopilot, analysisOn, printOn, plotOn);

T = t_vec';
if isfield(output ,'states')
    XT = output.states;
    YT = output.states.h;
    save('AeroBenchVV-master/F16_Sim/SimResults.mat','output','passFail');
else
    XT = output';
    YT = XT(:,12);
end
end
