global requirementID;
    cp_array = [7,3];
    simulationtime=zeros(1,5);
    nform = 0;
    nform  = nform+1;
    phi_cc{nform} ='[]_[0,100] (cc1pred)';
    phi_cc_name{nform} = 'CC1';
    nform  = nform+1;
    phi_cc{nform} ='[]_[0,70] (<>_[0,30] (cc2pred))';
    phi_cc_name{nform} = 'CC2';
    nform  = nform+1;
    phi_cc{nform} = '[]_[0,80] (([]_[0,20] (cc3pred1))  \/ (<>_[0,20] (cc3pred2)))';
    phi_cc_name{nform} = 'CC3';
    nform  = nform+1;
    phi_cc{nform} = '[]_[0,65] (<>_[0,30] ([]_[0,5] (cc4pred1)))';
    phi_cc_name{nform} = 'CC4';
    nform  = nform+1;
    phi_cc{nform} = '[]_[0,72] (<>_[0,8] (([]_[0,5] (cc5pred1)) -> ([]_(5,20) (cc5pred2))))';
    phi_cc_name{nform} = 'CC5';
    nform  = nform+1;
    phi_cc{nform} = '([]_[0,50] (ccxpred1)) /\ ([]_[0,50] (ccxpred2)) /\ ([]_[0,50] (ccxpred3)) /\ ([]_[0,50] (ccxpred4))';
    phi_cc_name{nform} = 'CCx';

    
    disp(' ')
    for j = 1:nform
        disp(['   ',num2str(j),' . phi_wt_',num2str(j),' = ',phi_cc{j}])
    end
    form_id = requirementID;


    phi=phi_cc{form_id};
    phi_no_comma=strrep(phi,',','_comma_');
    phi_name=phi_cc_name{form_id};
    disp(['Start falsifying Requirement: ',phi_name]);
    disp(['   ',num2str(form_id),' . ',phi_name,' = ',phi]);

    
    preds(1).str='cc1pred';
    preds(1).A = [0 0 0 -1 1];
    preds(1).b = 40;
   
    preds(2).str='cc2pred';
    preds(2).A = [0 0 0 1 -1];
    preds(2).b = -15;

    preds(3).str='cc3pred1';
    preds(3).A = [-1 1 0 0 0];
    preds(3).b = 20;

    preds(4).str='cc3pred2';
    preds(4).A = [0 0 0 1 -1];
    preds(4).b = -40;

    preds(5).str='cc4pred1';
    preds(5).A = [0 0 0 1 -1];
    preds(5).b = -8;

    preds(6).str='cc5pred1';
    preds(6).A = [1 -1 0 0 0];
    preds(6).b = -9;

    preds(7).str='cc5pred2';
    preds(7).A = [0 0 0 1 -1];
    preds(7).b = -9;
    
    preds(8).str='ccxpred1';
    preds(8).A = [1 -1 0 0 0];
    preds(8).b = -7.5;
    
    preds(9).str='ccxpred2';
    preds(9).A = [0 1 -1 0 0];
    preds(9).b = -7.5;
    
    preds(10).str='ccxpred3';
    preds(10).A = [0 0 1 -1 0];
    preds(10).b = -7.5;
    
    preds(11).str='ccxpred4';
    preds(11).A = [0 0 0 1 -1];
    preds(11).b = -7.5;

    opt.interpolationtype={'pconst','pconst'};

    init_cond = [];

    input_range = [0.0 1.0; 0.0 1.0];
    model = 'cars';
    sim_time=100;
    simTime=sim_time;
    opt.SampTime=0.01;
    warning off 

    






