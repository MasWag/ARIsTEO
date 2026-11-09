function example_pendulum_multi()
% EXAMPLE_PENDULUM_MULTI Runs aristeo_multi_prop on the Tutorial pendulum
% (Simulink) with two properties and checks the result bookkeeping.
%   matlab -batch "cd tests/multi_spec; example_pendulum_multi"
    setup_paths();
    here = fileparts(mfilename('fullpath'));
    tutorial = fullfile(here, '..', '..', 'Tutorial');
    add_sanitized_path(fullfile(tutorial, 'simgeneral'));
    addpath(fullfile(here, 'compat'));   % animinit, missing in recent MATLAB releases
    % SettingUp.m contains U+00A0, which recent MATLAB releases reject
    eval(strrep(fileread(fullfile(tutorial, 'SettingUp.m')), char(160), ' '));
    opt.n_refinement_rounds = 5;
    opt.optim_params.n_tests = 5;
    opt.nbr_Runs = 1;
    opt.runs = 1;
    opt.dispinfo = 0;
    phis = {phi, '[]_[0,10000] a'};
    rng(1);
    [results, inputs] = aristeo_multi_prop(model, init_cond, input_range, cp_array, phis, preds, TotSimTime, opt);
    R = results.run(1);
    rounds = nnz(R.selectedSpec);
    assert(R.nTests == 1 + rounds && rounds <= opt.n_refinement_rounds);
    assert(all(R.falsified) || rounds == opt.n_refinement_rounds);
    assert(isequal(R.falsified, ~isnan(R.falsifiedAtTest)));
    % violating "[] a" implies violating "[] (a /\ b)": phis{1} no later than phis{2}
    if R.falsified(2)
        assert(R.falsified(1) && R.falsifiedAtTest(1) <= R.falsifiedAtTest(2));
    end
    % abstraction in round 1 (surrogate learned from the initial simulation)
    assert(rounds == 0 || strcmp(R.absrefAction{1}, 'abstract'));
    assert(all(ismember(R.absrefAction(1:rounds), {'abstract', 'refine'})));
    fprintf('PENDULUM falsified = %s, falsifiedAtTest = %s, bestRobs = %s, selectedSpec = %s, actions = %s, nTests = %d, time = %.1fs\n', ...
        mat2str(R.falsified), mat2str(R.falsifiedAtTest), mat2str(R.bestRobs, 3), mat2str(R.selectedSpec), ...
        strjoin(R.absrefAction(1:rounds), ','), R.nTests, R.executiontime);
    fprintf('inputs falsified: %s\n', mat2str(cellfun(@(x) ~(isscalar(x) && isnan(x)), inputs)));
end
