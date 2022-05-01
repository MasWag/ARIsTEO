warning off;

global requirementID;
global analysisOn,
global printOn, 
global plotOn,
global model_err 
global InitAlt

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

preds(1).str = 'p1'; % p1 is system altitude >= 300 => -altitude <= -300
preds(1).A =  -1;
preds(1).b =  0;
preds(1).proj =  1; % Ax<=b corresponds to the first vector in YT (makes computation faster)

preds(2).str = 'p2'; %p2 is system GCAS mode ON (i.e. GCAS mode out >= 0.5) => -GCAS<=-0.5
preds(2).A = -1;
preds(2).b = -0.5;
preds(2).proj = 2;

preds(3).str = 'p3'; %p3 is system GCAS mode OFF (i.e. GCAS mode out <= 0.5)
preds(3).A = 1;
preds(3).b = 0.5;
preds(3).proj = 2;

preds(4).str = 'p4'; %p4 is system roll >= 0.02 => -roll<=-0.02 (combine p4 and p5) and roll <= 0.004
preds(4).A = [-1; 1];
preds(4).b = [-0.02; 0.04];
preds(4).proj = 3; 

preds(5).str = 'p6'; %p6 is system pitch >= 0.2 => -pitch<=-0.2 and pitch <= 0.28
preds(5).A = [-1;1];
preds(5).b = [-0.2; 0.28];
preds(5).proj = 4;


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

model = @blackboxF16;
init_cond = [pi/4+[-pi/20 pi/30]; -(pi/2)*0.8+[0 pi/20]; -pi/4+[-pi/8 pi/8]];
opt.black_box = 1;
opt.seed = 12222;



nform = 0;
nform  = nform+1;
phi_f16{nform} =phi;
phi_f16_name{nform} = 'F16a';      

disp(' ')
for j = 1:nform
    disp(['   ',num2str(j),' . phi_F16_',num2str(j),' = ',phi_f16{j}])
end
form_id = requirementID;

phi=phi_f16{form_id};
phi_no_comma=strrep(phi,',','_comma_');
phi_name=phi_f16_name{form_id};
disp(['Start falsifying Requirement: ',phi_name]);
disp(['   ',num2str(form_id),' . ',phi_name,' = ',phi]);


opt.interpolationtype={'pconst','pconst'};
cp_array = [];
input_range = [];

sim_time=tf;
simTime=sim_time;

    






