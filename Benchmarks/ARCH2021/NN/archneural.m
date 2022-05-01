
    warning off;
    global requirementID;
    u_ts=0.001;
    nform = 0;
    nform  = nform+1;
    phi_nn{nform} = '[]_[1,18] (!(pred)->(<>_[0,2]([]_[0,1] (pred))))';
    phi_nn_name{nform} = '(NN 0.005 0.03)'; 
    nform  = nform+1;
    phi_nn{nform} = '(<>_[0,1] (!(nnxpred1))) /\ (<>_[1,1.5] (([]_[0,0.5] (!(nnxpred2) /\ nnxpred3)) /\ ([]_[2,3] (!(nnxpred4) /\ nnxpred5)))))';
    phi_nn_name{nform} = '(NNx)'; 
    
    preds(1).str='pred';
    preds(1).A = [1 0];
    preds(1).b = 0;
    
    preds(2).str='nnxpred1';
    preds(2).A = [0 1];
    preds(2).b = 3.2;
    
    preds(3).str='nnxpred2';
    preds(3).A = [0 1];
    preds(3).b = 1.75;
    
    preds(4).str='nnxpred3';
    preds(4).A = [0 1];
    preds(4).b = 2.25;
    
    preds(5).str='nnxpred4';
    preds(5).A = [0 1];
    preds(5).b = 1.825;
    
    preds(6).str='nnxpred5';
    preds(6).A = [0 1];
    preds(6).b = 2.175;
    
    form_id = requirementID;
    phi=phi_nn{form_id};
    phi_no_comma='_[1.0_comma_ 18.0] (¬(abs((Pos - Ref)) ≤ (0.005 + (0.03 * abs(Ref)))) ⟹ ◇_[0.0_comma_ 2.0] □_[0.0_comma_ 1.0] (abs((Pos - Ref)) ≤ (0.005 + (0.03 * abs(Ref)))))';
    phi_name=phi_nn_name{form_id};
    disp(['Start falsifying Requirement: ',phi_name]);
    disp(['   ',num2str(form_id),' . ',phi_name,' = ',phi]);

    opt.interpolationtype={'pconst'};
    %opt.interpolationtype={'pchip'};
    sim_time=40;
    simTime=sim_time;
    init_cond = [];

    input_range = [1 3];
    cp_array = 3;
    model = 'nn';
    opt.SampTime=0.01;










