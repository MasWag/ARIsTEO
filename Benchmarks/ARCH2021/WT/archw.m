global requirementID;    


    init_SimpleWindTurbine;
    nform = 0;
    nform  = nform+1;
    phi_wt{nform} = '[]_[30,630] (p1)';
    phi_wt_name{nform} = 'WT1'; 
    nform  = nform+1;
    phi_wt{nform} = '[]_[30,630](p2 /\ p3)';
    phi_wt_name{nform} = 'WT2'; 
    nform  = nform+1;
    phi_wt{nform} = '[]_[30,630](p4)';
    phi_wt_name{nform} = 'WT3'; 
    nform  = nform+1;
    phi_wt{nform} = '[]_[30,630](<>_[0,5] (p5 /\ p6))';
    phi_wt_name{nform} = 'WT4'; 
    
    disp(' ')
    for j = 1:nform
        disp(['   ',num2str(j),' . phi_wt_',num2str(j),' = ',phi_wt{j}])
    end
    form_id = requirementID;

    phi=phi_wt{form_id};
    phi_no_comma=strrep(phi,',','_comma_');
    phi_name=phi_wt_name{form_id};
    disp(['Start falsifying Requirement: ',phi_name]);
    disp(['   ',num2str(form_id),' . ',phi_name,' = ',phi]);
    preds(1).str = 'p1';
    preds(1).A = [1 0 0 0 0 0];
    preds(1).b = 14.2;
    
    preds(2).str = 'p2';
    preds(2).A = [0 0 -1 0 0 0];
    preds(2).b = -21000;

    preds(3).str = 'p3';
    preds(3).A = [0 0 1 0 0 0];
    preds(3).b = 47500;
    
    preds(4).str = 'p4';
    preds(4).A = [0 0 0 0 1 0];
    preds(4).b = 14.3;
    
    preds(5).str = 'p5';
    preds(5).A = [0 0 0 0 -1 1];
    preds(5).b = 1.6;
    
    preds(6).str = 'p6';
    preds(6).A = [1 0 0 0 1 -1];
    preds(6).b = 1.6;

    opt.interpolationtype={'pconst'};
    sim_time=630;
    simTime=sim_time;

    init_cond = [];

    input_range = [8 16];
    cp_array = 126;
    model = 'windturbine';
    warning off 

