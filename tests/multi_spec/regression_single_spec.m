function regression_single_spec(mode, varargin)
% REGRESSION_SINGLE_SPEC Same-seed comparison of the single-specification
% aristeo between two ARIsTEO source trees (e.g. master and this branch).
%
%   regression_single_spec('run', aristeo_dir, out_mat [, with_pendulum])
%       runs aristeo from aristeo_dir and saves the results to out_mat
%   regression_single_spec('compare', mat_a, mat_b)
%       asserts that both result files are identical
%
% See run_regression.sh for the complete procedure.
    switch mode
        case 'run'
            run_all(varargin{:});
        case 'compare'
            compare(varargin{:});
        otherwise
            error('unknown mode %s', mode);
    end
end

function run_all(aristeo_dir, out_mat, with_pendulum)
    if nargin < 3
        with_pendulum = false;
    end
    setup_paths(aristeo_dir);
    phis = {'[]_[0,5] a', '[]_[0,5] b', '[]_[0,5] d'};
    res = struct('name', {}, 'run', {});
    for i = 1:numel(phis)
        for seed = 1:3
            [model, init_cond, input_range, cp_array, preds, TotSimTime, opt] = lag_setup(5);
            rng(seed);
            r = aristeo(model, init_cond, input_range, cp_array, phis{i}, preds, TotSimTime, opt);
            res(end+1) = struct('name', sprintf('lag %s seed %d', phis{i}, seed), 'run', strip_times(r.run(1))); %#ok<AGROW>
        end
    end
    if with_pendulum
        here = fileparts(mfilename('fullpath'));
        tutorial = fullfile(here, '..', '..', 'Tutorial');
        add_sanitized_path(fullfile(tutorial, 'simgeneral'));
        addpath(fullfile(here, 'compat'));   % animinit, missing in recent MATLAB releases
        % SettingUp.m contains U+00A0, which recent MATLAB releases reject
        eval(strrep(fileread(fullfile(tutorial, 'SettingUp.m')), char(160), ' '));
        opt.n_refinement_rounds = 3;
        opt.optim_params.n_tests = 5;
        opt.nbr_Runs = 1;
        opt.runs = 1;
        opt.dispinfo = 0;
        rng(1);
        r = aristeo(model, init_cond, input_range, cp_array, phi, preds, TotSimTime, opt);
        res(end+1) = struct('name', 'pendulum tutorial seed 1', 'run', strip_times(r.run(1)));
    end
    save(out_mat, 'res');
    fprintf('saved %d results to %s\n', numel(res), out_mat);
end

function r = strip_times(r)
% wall-clock measurements naturally differ between executions
    for f = {'executiontime', 'falsificationtime', 'absreftime', 'simtime', 'searchTime', 'checkTime', 'time'}
        if isfield(r, f{1})
            r = rmfield(r, f{1});
        end
    end
end

function compare(mat_a, mat_b)
    a = load(mat_a); b = load(mat_b);
    assert(numel(a.res) == numel(b.res), 'different number of results');
    for i = 1:numel(a.res)
        assert(strcmp(a.res(i).name, b.res(i).name));
        assert(isequaln(a.res(i).run, b.res(i).run), 'results differ for %s', a.res(i).name);
        fprintf('PASS identical: %s (bestRob = %g, nTests = %d)\n', a.res(i).name, a.res(i).run.bestRob, a.res(i).run.nTests);
    end
    fprintf('SINGLE-SPEC REGRESSION PASSED (%d cases)\n', numel(a.res));
end
