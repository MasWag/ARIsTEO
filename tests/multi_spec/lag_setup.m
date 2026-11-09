function [model, init_cond, input_range, cp_array, preds, TotSimTime, opt] = lag_setup(n_rounds)
% LAG_SETUP Common configuration for the multi-spec tests on lag_sut.
%   Constant input (one control point) in [-2, 2].
%   Predicates on y:  a: y <= 1.5   b: -y <= 1.5   c: y <= 1.0   d: y <= 3.0
%                     e: y <= -3.0 (violated by every trace)
    model = @lag_sut;
    init_cond = [];
    input_range = [-2 2];
    cp_array = 1;
    TotSimTime = 5;
    preds(1).str = 'a'; preds(1).A = 1;  preds(1).b = 1.5;
    preds(2).str = 'b'; preds(2).A = -1; preds(2).b = 1.5;
    preds(3).str = 'c'; preds(3).A = 1;  preds(3).b = 1.0;
    preds(4).str = 'd'; preds(4).A = 1;  preds(4).b = 3.0;
    preds(5).str = 'e'; preds(5).A = 1;  preds(5).b = -3.0;
    opt = aristeo_options();
    opt.black_box = 1;
    opt.interpolationtype = {'const'};
    opt.SampTime = 0.1;
    opt.n_refinement_rounds = n_rounds;
    opt.nbr_Runs = 1;
    opt.runs = 1;
    opt.fals_at_zero = 0;
    opt.abstraction_algorithm = 'ss';
    opt.nx = 1;
    opt.optim_params.n_tests = 20;
    opt.dispinfo = 0;
    opt.dispinfoaristeo = 0;
end
