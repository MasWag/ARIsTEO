
    phi = '[]_[30,35] (p1/\p2)';
    phi_no_comma=strrep(phi,',','_comma_');
    phi_name='SCa';
    disp(['Start falsifying Requirement: ',phi_name]);
    disp([' 1 . ',phi_name,' = ',phi]);

    preds(1).str = 'p1';  
    preds(1).A =  [0 0 0 1];
    preds(1).b =  87.5;  

    preds(2).str = 'p2';  
    preds(2).A =  [0 0 0 -1];
    preds(2).b =  -87;

    opt.interpolationtype={'pconst'};

    sim_time=35;
    simTime=sim_time;
    init_cond = [];

    input_range = [3.99 ,4.01];
    cp_array = 20;
    model = 'stc';
    opt.SampTime=0.01;
    warning off 








