% This is a demo for the benchmarks presented in the ARCH 2017 competition
%
% We present the Powertrain Benchmark 
%
% (C) Adel Dokhanchi, Bardh Hoxha, Shakiba Yaghoubi, 2017 Arizona State University
    %opt=aristeo_options();
    measureTime = 1;
    i=0;
    eta = 1;
    % parameter h used for event definition
    h = 0.05;
    % parameter related to the period of the pulse signal
    zeta_min = 5;

    Ut = 0.008;

    low=8.8;
    high=40;

    taus = 10 + eta;
    
    % default settings
    spec_num = 1; %specification measurement
    fuel_inj_tol = 1.0; 
    MAF_sensor_tol = 1.0;
    AF_sensor_tol = 1.0;
    fault_time = 100; 
    
    i = i+1;
    preds(i).str = 'low'; % for the pedal input signal
    preds(i).A =  [0 0 1] ;
    preds(i).b =  low ;
    i = i+1;

    preds(i).str = 'high'; % for the pedal input signal
    preds(i).A =  [0 0 -1] ;
    preds(i).b =  -high ;
    i = i+1;
    % rise event is represented as low/\<>_(0,h)high
    % fall event is represented as high/\<>_(0,h)low
    preds(i).str = 'norm'; % mode < 0.5 (normal mode = 0)
    preds(i).A =  [0 1 0] ;  
    preds(i).b =  0.5 ;
    i = i+1;
    preds(i).str = 'pwr'; % mode >0.5 (power mode = 1)
    preds(i).A =  [0 -1 0] ;
    preds(i).b =  -0.5 ;
    i = i+1;
    preds(i).str = 'utr'; % u<=Ut
    preds(i).A =  [1 0 0] ;
    preds(i).b =  Ut ;
    i = i+1;
    preds(i).str = 'utl'; % u>=-Ut
    preds(i).A =  [-1 0 0] ;
    preds(i).b =  Ut ;
    i = i+1;

    AFC27 = ['[]_[11,50](!((low/\<>_(0,' num2str(h) ')high) \/ (high/\<>_(0,' num2str(h) ')low)))'];
    AFC29 = '[]_[11,50](utr /\ utl)';
    AFC33 = '[]_[11,50](utr /\ utl)';

    nform = 0;
    nform  = nform+1;
    phi_afc{nform} = ['[]_[11,50](!((low/\<>_(0,' num2str(h) ')high) \/ (high/\<>_(0,' num2str(h) ')low)))'];
    nform  = nform+1;
    phi_afc{nform} ='[]_[11,50](utr /\ utl)';
    nform  = nform+1;
    phi_afc{nform} ='[]_[11,50](utr /\ utl)';
    disp(' ')
    for j = 1:nform
        disp(['   ',num2str(j),' . phi_at_',num2str(j),' = ',phi_afc{j}])
    end
    form_id = input('Choose a specification to falsify:');


    phi=phi_afc{form_id};

    %% Falsification parameters options
    opt.black_box = 1;
    opt.SampTime = 0.05;
    opt.falsification=1;
%---------------------------------------------------------------------   
    init_cond = [];
    cp_array = [1;10]; 
    opt.interpolationtype = {'const', 'pconst'};
    if strcmp(opt.optimization_solver,'SA_Taliro')
        opt.optim_params.dispStart= 0.9;
        opt.optim_params.dispAdap = 2; 
    end
    input_range = [900  1100; 0 61.1]; 
    opt.seed=2016;
    if (nform==3)
        input_range = [900  1100; 61.2 81.2];
    end
    model = 'AbstractFuelControl_M1';
    disp(' ')
    disp(['Specification :', phi])
    opt.optim_params.n_tests = 100; % number of tests
    sim_time=50;
    simTime=sim_time;
