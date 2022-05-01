warning off;

global requirementID;
global analysisOn,
global printOn, 
global plotOn,
global model_err 
global InitAlt

InitAlt = 4040;
model_err = false;

analysisOn = false;
printOn = false;
plotOn = false;
backCalculateBestSamp = false;

% Simulation time & Requirements (run " help staliro" for more information)
t0 = 0;
tf = 15;
preds(1).str = 'p1';  
preds(1).A =  -1;
preds(1).b =  0;  
model = @blackboxF16;            % Black box model that calls Simulink through staliro
opt.black_box = 1;

nform = 0;
nform  = nform+1;
phi_f16{nform} ='[]_[0,15] p1';
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
% Search space for aircraft's initial conditions   
init_cond = [pi/4+[-pi/20 pi/30]; -(pi/2)*0.8+[0 pi/20]; -pi/4+[-pi/8 pi/8]];
cp_array = [];
input_range = [];

sim_time=tf;
simTime=sim_time;

    






