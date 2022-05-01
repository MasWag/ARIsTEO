
global initialState
global x_f16_0
global sys

%addpath(genpath('AeroBenchVV-develop'))

InitAlt = 2338; 
model_err = false;

analysisOn = false;
printOn = false;
plotOn = false;
backCalculateBestSamp = false;

% Simulation time & Requirements (run " help staliro" for more information)
t0 = 0;
tf = 15;
% in words the requirement is
% [](Altitude>300) /\ [] ( ( (GCAS>=0.5) /\ X (GCAS<=0.5) ) -> X ( Roll>=0.02 /\ Roll <= 0.04 /\ Pitch>=0.2 /\ Pitch <=0.28 ) ) /\ <>_[0,7] ( GCAS_On /\ X GCAS_Off)
phi = '[]p1 /\ []((p2 /\ X p3) -> X (p4 /\ p6)) /\ <>_[0,7](p2 /\ X p3)';

pred(1).str = 'p1'; % p1 is system altitude >= 300 => -altitude <= -300
pred(1).A =  -1;
pred(1).b =  0;
pred(1).proj =  1; % Ax<=b corresponds to the first vector in YT (makes computation faster)

pred(2).str = 'p2'; %p2 is system GCAS mode ON (i.e. GCAS mode out >= 0.5) => -GCAS<=-0.5
pred(2).A = -1;
pred(2).b = -0.5;
pred(2).proj = 2;

pred(3).str = 'p3'; %p3 is system GCAS mode OFF (i.e. GCAS mode out <= 0.5)
pred(3).A = 1;
pred(3).b = 0.5;
pred(3).proj = 2;

pred(4).str = 'p4'; %p4 is system roll >= 0.02 => -roll<=-0.02 (combine p4 and p5) and roll <= 0.004
pred(4).A = [-1; 1];
pred(4).b = [-0.02; 0.04];
pred(4).proj = 3; 

pred(5).str = 'p6'; %p6 is system pitch >= 0.2 => -pitch<=-0.2 and pitch <= 0.28
pred(5).A = [-1;1];
pred(5).b = [-0.2; 0.28];
pred(5).proj = 4;


%configure F16 sim
cd('AeroBenchVV-develop/src/main');
SimConfig;
cd('../../..');

initialState(12) = InitAlt;     % Inital Altitude of the System set appropriately 
x_f16_0(12) = InitAlt;          % Inital Altitude of the System set appropriately 
t_end = tf;

% Update Simulink diagram to account for code changes
sys = 'AeroBenchSim_2019a';
load_system(sys)

model = @blackboxF16;            % Black box model that calls 5Simulink through staliro
nbstarts = 1;                   % # of Runs
nbiter = 300;                   % Max # of simulations

% Search space for aircraft's initial conditions   
Xrange = [pi/4+[-pi/20 pi/30]; -(pi/2)*0.8+[0 pi/20]; -pi/4+[-pi/8 pi/8]];

% Staliro's options
opt = staliro_options(); %(See staliro_options help file)
opt.optimization_solver = 'UR_Taliro';

opt.runs = nbstarts;
opt.black_box = 1;
opt.optim_params.n_tests = 10;
opt.falsification = 1;

warning off;

%note here we seperate the 50 falsification runs into 50 calls of S-Taliro
%to save the results observed after each indivdual run, rather than
%completing all 50 and then saving.

    [res, ~] = staliro(model,Xrange,[],[],phi,pred,tf,opt);
    %save(['F16_UR_history_results_300tests',num2str(runs)],'results','history')



