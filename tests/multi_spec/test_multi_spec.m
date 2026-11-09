function test_multi_spec()
% TEST_MULTI_SPEC Assertion-based tests of aristeo_multi_prop on the
% deterministic black-box SUT lag_sut (see lag_setup for the predicates).
%
%   matlab -batch "cd tests/multi_spec; test_multi_spec"
%
% The seeds below were chosen so that the stochastic surrogate search
% reaches the situation each test is about; the properties asserted are
% the ones that must hold for ANY run (structure, bookkeeping, budget).

    setup_paths();
    A = '[]_[0,5] a';   % falsified iff some u > 1.5
    B = '[]_[0,5] b';   % falsified iff some u < -1.5
    C = '[]_[0,5] c';   % falsified iff some u > 1.0 (implied by violating A)
    D = '[]_[0,5] d';   % cannot be falsified (|y| <= 2)
    E = '[]_[0,5] e';   % falsified by every trace

    %% 1. two specifications falsified by different trajectories
    R = run_multi({A, B}, 15, 3);
    check_invariants(R);
    assert(all(R.falsified), 'T1: both specifications must be falsified');
    assert(R.falsifiedAtTest(1) ~= R.falsifiedAtTest(2), ...
        'T1: A and B cannot be falsified by the same (constant-input) trace');
    pass('T1 two specs, different trajectories: falsifiedAtTest = %s', mat2str(R.falsifiedAtTest));

    %% 2. one trajectory falsifies several specifications
    R = run_multi({A, C}, 15, 3);
    check_invariants(R);
    assert(all(R.falsified), 'T2: both specifications must be falsified');
    assert(R.falsifiedAtTest(1) == R.falsifiedAtTest(2), ...
        'T2: the trace falsifying A must be recorded as falsifying C too');
    assert(~any(R.selectedSpec == 2), 'T2: C was falsified with A and must never be selected');
    pass('T2 one trace falsifies two specs: falsifiedAtTest = %s', mat2str(R.falsifiedAtTest));

    %% 3. a falsified specification is never selected again; selection = first remaining
    for seed = 1:3
        R = run_multi({A, B, C}, 10, seed);
        check_invariants(R);
    end
    R = run_multi({E, A}, 10, 3);
    check_invariants(R);
    assert(R.falsified(1) && R.falsifiedAtTest(1) == 1, 'T3: E must be falsified by the initial simulation');
    assert(~any(R.selectedSpec == 1), 'T3: E was falsified initially and must never be selected');
    pass('T3 selection policy (seeds 1-3 for {A,B,C}, and {E,A})');

    %% 4. surrogate reuse: one abstraction, refinement continues across the switch
    R = run_multi({A, B}, 10, 2);   % seed 2: A falsified first, then B is searched
    check_invariants(R);
    rounds = nnz(R.selectedSpec);
    sw = find(diff(R.selectedSpec(1:rounds)) ~= 0, 1) + 1;
    assert(~isempty(sw), 'T4: expected a switch of the selected specification');
    assert(nnz(strcmp(R.absrefAction(1:rounds), 'abstract')) == 1, ...
        'T4: the surrogate must be abstracted only once');
    assert(strcmp(R.absrefAction{sw}, 'refine'), ...
        'T4: after a switch the existing surrogate must be refined, not re-abstracted');
    pass('T4 surrogate reused across switch at round %d: %s', sw, strjoin(R.absrefAction(1:rounds), ','));

    %% 5. budget exhaustion and partial success
    R = run_multi({A, D}, 3, 3);
    check_invariants(R);
    assert(isequal(R.falsified, [true false]), 'T5: expected partial success [true false]');
    assert(R.nTests == 4 && nnz(R.selectedSpec) == 3, 'T5: 1 initial + 3 rounds of budget');
    assert(isnan(R.falsifiedAtTest(2)) && R.bestRobs(2) > 0, 'T5: D must be reported as not falsified');
    assert(~R.timedOut, 'T5: stopped by the rounds budget, not by a timeout');
    assert(isscalar(R.inputs{2}) && isnan(R.inputs{2}), 'T5: inputs{2} must be NaN');
    assert(~any(isnan(R.inputs{1}(:))), 'T5: inputs{1} must hold the falsifying input');
    pass('T5 budget exhausted: falsified = %s, nTests = %d', mat2str(R.falsified), R.nTests);

    %% 6. all specifications falsified by the initial simulation
    R = run_multi({E}, 5, 1);
    check_invariants(R);
    assert(R.falsified && R.nTests == 1 && nnz(R.selectedSpec) == 0, ...
        'T6: no refinement round may be executed');
    pass('T6 everything falsified by the initial simulation: nTests = %d', R.nTests);

    %% 7. per-specification predicates (cell array) give the same run as shared predicates
    [~,~,~,~,preds] = lag_setup(1);
    R1 = run_multi({A, B}, 15, 3);
    R2 = run_multi({'[]_[0,5] p', '[]_[0,5] p'}, 15, 3, ...
        {rename_pred(preds(1), 'p'), rename_pred(preds(2), 'p')});
    assert(isequal(R1.falsifiedAtTest, R2.falsifiedAtTest) && isequal(R1.bestRobs, R2.bestRobs), ...
        'T7: per-spec predicates must behave like the shared predicate array');
    pass('T7 per-specification predicates');

    %% 8. one specification: aristeo_multi_prop == aristeo (same seed)
    for seed = 1:3
        [model, init_cond, input_range, cp_array, preds, TotSimTime, opt] = lag_setup(5);
        rng(seed); ro = aristeo(model, init_cond, input_range, cp_array, A, preds, TotSimTime, opt);
        rng(seed); rm = aristeo_multi_prop(model, init_cond, input_range, cp_array, {A}, preds, TotSimTime, opt);
        o = ro.run(1); m = rm.run(1);
        assert(isequal(o.bestRob, m.bestRob) && isequal(o.nTests, m.nTests), ...
            'T8: bestRob/nTests differ for seed %d', seed);
        assert(isequal(isfield(o, 'bestInput'), isfield(m, 'bestInput')), 'T8: bestInput presence differs');
        if isfield(o, 'bestInput')
            assert(isequal(o.bestInput, m.bestInput), 'T8: bestInput differs for seed %d', seed);
        end
    end
    pass('T8 single specification identical to aristeo (seeds 1-3)');

    %% 9. timeout: whole-task wall-clock budget, checked before each round
    R = run_multi({A, D}, 1000, 3, [], 0);
    check_invariants(R);
    assert(R.timedOut && R.nTests == 1 && nnz(R.selectedSpec) == 0, ...
        'T9: timeout 0 must stop after the initial simulation');
    R = run_multi({A, D}, 1000, 3, [], 3);
    check_invariants(R);
    rounds = nnz(R.selectedSpec);
    assert(R.timedOut && rounds > 0 && rounds < 1000, 'T9: expected a stop by the timeout');
    assert(R.executiontime >= 3, 'T9: stopped before the timeout');
    assert(R.falsified(1) && ~R.falsified(2), 'T9: expected partial success [true false]');
    t9time = R.executiontime;
    R = run_multi({A, B}, 15, 3, [], 1e6);
    check_invariants(R);
    assert(~R.timedOut && all(R.falsified), 'T9: a large timeout must not change the result');
    pass('T9 timeout: %d rounds in %.1fs with timeout 3s', rounds, t9time);

    fprintf('ALL MULTI-SPEC TESTS PASSED\n');
end

function R = run_multi(phis, n_rounds, seed, preds_override, timeout)
    [model, init_cond, input_range, cp_array, preds, TotSimTime, opt] = lag_setup(n_rounds);
    if nargin >= 4 && ~isempty(preds_override)
        preds = preds_override;
    end
    if nargin < 5
        timeout = [];
    end
    rng(seed);
    [results, inputs] = aristeo_multi_prop(model, init_cond, input_range, cp_array, phis, preds, TotSimTime, opt, timeout);
    R = results.run(1);
    R.inputs = inputs;
    R.phis = results.phis;
    R.n_rounds = n_rounds;
end

function check_invariants(R)
% Properties that must hold for every run.
    n = numel(R.phis);
    rounds = nnz(R.selectedSpec);
    % budget: one initial simulation + one per round, never more than allowed
    assert(R.nTests == 1 + rounds, 'nTests (%d) must equal 1 + rounds (%d)', R.nTests, rounds);
    assert(rounds <= R.n_rounds, 'more rounds than the budget');
    assert(all(R.selectedSpec(rounds+1:end) == 0), 'rounds must be contiguous');
    % termination: stop only when everything is falsified or a budget is exhausted
    assert(all(R.falsified) || rounds == R.n_rounds || R.timedOut, 'stopped early with unfalsified specifications');
    assert(~R.timedOut || (~all(R.falsified) && rounds < R.n_rounds), 'timedOut set without a timeout stop');
    if all(R.falsified) && rounds > 0
        assert(max(R.falsifiedAtTest) == R.nTests, 'must stop right after the last falsification');
    end
    % selection: in round t, the first specification not falsified by simulations 1..t
    for t = 1:rounds
        fals_before = R.falsifiedAtTest <= t;     % NaN compares false
        expected = find(~fals_before, 1);
        assert(R.selectedSpec(t) == expected, 'round %d selected %d instead of %d', t, R.selectedSpec(t), expected);
    end
    % bookkeeping consistency
    assert(isequal(R.falsified, ~isnan(R.falsifiedAtTest)), 'falsified/falsifiedAtTest mismatch');
    assert(all(R.bestRobs(R.falsified) < 0 | R.falsifiedAtTest(R.falsified) == 1), 'falsified spec without negative robustness');
    assert(all(R.bestRobs(~R.falsified) >= 0), 'unfalsified spec with negative robustness');
    for k = 1:n
        assert(R.falsified(k) == ~(isnumeric(R.inputs{k}) && isscalar(R.inputs{k}) && isnan(R.inputs{k})), ...
            'inputs{%d} inconsistent with falsified', k);
    end
    % cumulative time accounting
    assert(R.executiontime >= sum(R.absreftime) + sum(R.falsificationtime), 'execution time not cumulative');
    ft = R.falsifiedAtTime(R.falsified);
    at = R.falsifiedAtTest(R.falsified);
    assert(all(ft >= 0 & ft <= R.executiontime), 'falsifiedAtTime out of range');
    [~, order] = sort(at);
    assert(all(diff(ft(order)) >= 0), 'falsifiedAtTime must be non-decreasing in falsifiedAtTest');
end

function p = rename_pred(p, name)
    p.str = name;
end

function pass(fmt, varargin)
    fprintf(['PASS ' fmt '\n'], varargin{:});
end
