% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu
% This is a demo for using S-TALIRO with the Automatic Transimssion
% Simulink Demo.
%
% Demo for falsifying the specification '!(<>r1 /\ <>r2)'
% The predicates r1 and r2 correspond to the sets R1 and R2 in the paper:
% Zhao, Q.; Krogh, B. H. & Hubbard, P. Generating Test Inputs for Embedded
% Control Systems IEEE Control Systems Magazine, 2003, August, 49-57

% (C) G. Fainekos 2011 - Arizona State Univeristy
global requirementID;
v=ver('Matlab');
if(isequal(v.Release,'(R2017a)'))

model = 'Autotrans_shiftprev';
else
if(isequal(v.Release,'(R2018a)'))
model = 'sldemo_autotrans_mod01_2018a';
else
model = @blackbox_autotrans;
end
end
time=zeros(1,5);
nform = 0;
% nform  = nform+1;
% phi_at{nform} = '[]_[0, 30] ((!(gear1) /\ X (gear1))-> X []_[0, 2.5] (gear1))';
% nform  = nform+1;
% phi_at{nform} = '[]_[0, 30] ((!(gear2) /\ X (gear2))-> X []_[0, 2.5] (gear2))';
% nform  = nform+1;
% phi_at{nform} = '[]_[0, 30] ((!(gear3) /\ X (gear3))-> X []_[0, 2.5] (gear3))';
% nform  = nform+1;
% phi_at{nform} = '[]_[0, 30] ((!(gear4) /\ X (gear4))-> X []_[0, 2.5] (gear4))';
nform  = nform+1;
phi_at{nform} = '[]_[0,20] speed120';
phi_at_name{nform} = 'AT1';
nform  = nform+1;
phi_at{nform} = '[]_[0,10] rpm4750';
phi_at_name{nform} = 'AT2';
nform  = nform+1;
phi_at{nform} = '([]_[0, 30] (rpm3000) ->[]_[0, 4] (speed35))';
phi_at_name{nform} = 'AT6a';
nform  = nform+1;
phi_at{nform} = '([]_[0, 30] (rpm3000) ->[]_[0, 8] (speed50))';
phi_at_name{nform} = 'AT6b';
time(nform)=30;
nform  = nform+1;
phi_at{nform} = '([]_[0, 30] (rpm3000) ->[]_[0, 20] (speed65))';
phi_at_name{nform} = 'AT6c';
nform  = nform+1;
phi_at{nform} = strcat('(',phi_at{3},'/\',phi_at{4},'/\',phi_at{5},')');
phi_at_name{nform} = 'AT6abc';

disp(' ')
for j = 1:nform
disp(['   ',num2str(j),' . ',phi_at_name{j},' = ',phi_at{j}])
end
% form_id = input('Choose a specification to falsify:');
form_id = requirementID;

phi=phi_at{form_id};
phi_no_comma=strrep(phi,',','_comma_');
phi_name=phi_at_name{form_id};
disp(['Start falsifying Requirement: ',phi_name]);
disp(['   ',num2str(form_id),' . ',phi_name,' = ',phi]);

ii = 1;
preds(ii).str = 'gear1';
preds(ii).A = [];
preds(ii).b = [];
preds(ii).loc = 1;

ii = ii+1;
preds(ii).str = 'gear2';
preds(ii).A = [];
preds(ii).b = [];
preds(ii).loc = 2;

ii = ii+1;
preds(ii).str = 'gear3';
preds(ii).A = [];
preds(ii).b = [];
preds(ii).loc = 3;

ii = ii+1;
preds(ii).str = 'gear4';
preds(ii).A = [];
preds(ii).b = [];
preds(ii).loc = 4;

ii = ii+1;
preds(ii).str='speed120';
preds(ii).A = [1 0];
% preds(ii).A = [1];
% preds(ii).proj = 1;
preds(ii).b = 120;
preds(ii).loc = 1;

ii = ii+1;
preds(ii).str='speed35';
preds(ii).A = [1 0];
% preds(ii).A = [1];
% preds(ii).proj = 1;
preds(ii).b = 35;
preds(ii).loc = 1:4;

ii = ii+1;
preds(ii).str='speed50';
preds(ii).A = [1 0];
% preds(ii).A = [1];
% preds(ii).proj = 1;
preds(ii).b = 50;
preds(ii).loc = 1:4;

ii = ii+1;
preds(ii).str='speed65';
preds(ii).A = [1 0];
% preds(ii).A = [1];
% preds(ii).proj = 1;
preds(ii).b = 65;
preds(ii).loc = 1:4;


ii = ii+1;
preds(ii).str='rpm3000';
preds(ii).A = [0 1];
% preds(ii).A = [1];
% preds(ii).proj = 2;
preds(ii).b = 3000;
preds(ii).loc = 1:4;

ii = ii+1;
preds(ii).str='rpm4750';
preds(ii).A = [0 1];
% preds(ii).A = [1];
% preds(ii).proj = 2;
preds(ii).b = 4750;
preds(ii).loc = 1:4;
% if nform<5
% opt.taliro_metric = 'hybrid_inf';
% end
opt.SampTime=0.01;
opt.interpolationtype={'pchip','pchip'};
opt.spec_space = 'Y';
opt.black_box = 1;
sim_time=50;
simTime=sim_time;
cp_array = [7,3];
init_cond = [];
opt.loc_traj = 'end';
input_range = [0 100;0 325];


