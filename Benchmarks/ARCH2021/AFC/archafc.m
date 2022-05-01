% This is a demo for the benchmarks presented in the ARCH 2017 competition
%
% We present the Powertrain Benchmark 
%
% (C) Adel Dokhanchi, Bardh Hoxha, Shakiba Yaghoubi, 2017 Arizona State University
    warning off;
    global requirementID;
    form_id = requirementID;
    load_specs_and_model;
    opt.black_box = 1;
    opt.SampTime = 0.01;
    opt.falsification=1;
%---------------------------------------------------------------------   
    sim_time=50;
    simTime=sim_time;
    cp_array = [1 10]; 
    opt.interpolationtype = {'const', 'pconst'};
        

    disp(' ')
    disp(['Specification :' phi_afc{form_id},])


    phi=phi_afc{form_id};
    phi_no_comma=strrep(phi,',','_comma_');
    phi_name=phi_afc_name{form_id};
    disp(['Start falsifying Requirement: ',phi_name]);
    disp(['   ',num2str(form_id),' . ',phi_name,' = ',phi]);
