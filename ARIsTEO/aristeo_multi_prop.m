% Copyright 2021 University of Luxembourg

% SPDX-FileCopyrightText: 2021 University of Luxembourg
% SPDX-License-Identifier: GPL-2.0-or-later
% Authors: see Authors.txt

% function aristeo_multi_prop - Falsifies all of several STL specifications
%
% USAGE
%
%         [results,inputs] = aristeo_multi_prop(model, init_cond, input_range, cp_array, phis, preds, TotSimTime, aristeo_options)
%         [results,inputs] = aristeo_multi_prop(..., aristeo_options, timeout)
%
% DESCRIPTION :
%
%   ARISTEO_MULTI_PROP runs the ARIsTEO approximation-refinement loop of
%   ARISTEO (the code of aristeo.m, unchanged except for the lines marked
%   "MULTI-SPEC") until ALL the given specifications are falsified or the
%   budget is exhausted. The surrogate model and the identification data
%   are learned once per run and are reused across specifications:
%
%     - the initial SUT simulation (firstcheck) is evaluated against every
%       specification;
%     - in each refinement round the first not-yet-falsified specification
%       (in the given order) is selected and the original
%       abstraction/refinement, falsification and check steps are executed
%       for it;
%     - the SUT trace produced by check is also evaluated against every
%       other not-yet-falsified specification (no additional simulation);
%     - abstraction/refinement follow the original rule (abstraction at the
%       first round or if the previous abstraction failed, refinement
%       otherwise); the surrogate and data are NOT reset when a
%       specification is falsified. As in the original check, new
%       identification data is added only if the trace does not falsify the
%       selected specification.
%
%   aristeo_options.n_refinement_rounds is a budget for the WHOLE task
%   (all specifications together), not per specification. The total number
%   of SUT simulations of a run is results.run(ii).nTests (initial
%   simulation + one per refinement round).
%
%   The optional timeout (in seconds, default Inf) is a wall-clock budget
%   for the WHOLE task of each run, measured from the start of the run
%   (initial simulation and abstraction included). It is checked, like
%   n_refinement_rounds, before starting a refinement round: no new round
%   is started once the elapsed time reaches the timeout, but a round that
%   has already started is completed (the time of a run can therefore
%   exceed the timeout by at most one round).
%
% INPUTS :
%
%   - model, init_cond, input_range, cp_array, TotSimTime, aristeo_options :
%       as in aristeo (type "help aristeo"). All the specifications share
%       them.
%
%   - phis : cell array of specifications (a single string is accepted).
%
%   - preds : either a predicate array shared by all the specifications, or
%       a cell array with one predicate array per specification.
%
%   - timeout : optional wall-clock budget in seconds for each run (default
%       Inf, i.e., only n_refinement_rounds limits the search).
%
% OUTPUTS :
%
%   - results : as in aristeo, i.e., results.run(ii) has the fields bestRob,
%       bestInput, nTests, executiontime, falsificationtime, absreftime,
%       simtime, searchTime, checkTime computed by the original code (bestRob
%       and bestInput refer to the specification selected in each round).
%       In addition:
%         results.phis                    : the specifications
%         results.run(ii).falsified(k)    : true if phis{k} was falsified
%         results.run(ii).falsifiedAtTest(k) : index of the SUT simulation
%                                           that falsified phis{k} (1 = initial
%                                           simulation), NaN otherwise
%         results.run(ii).falsifiedAtTime(k) : time (s) from the start of the
%                                           run until phis{k} was falsified
%         results.run(ii).bestRobs(k)     : best robustness of phis{k} over all
%                                           SUT simulations of the run
%         results.run(ii).bestInputs{k}   : input achieving bestRobs(k)
%         results.run(ii).selectedSpec(t) : specification selected in round t
%         results.run(ii).absrefAction{t} : 'abstract' or 'refine' in round t
%         results.run(ii).timedOut       : true if the run stopped because of
%                                           the timeout with specifications left
%
%   - inputs : inputs{k} is a falsifying input of phis{k} (from the first run
%       that falsified it), NaN if phis{k} was not falsified.
%
% EXAMPLE :
%
%   phis = {'[]_[0,10000] (a/\b)', '[]_[0,10000] a'};
%   [results, inputs] = aristeo_multi_prop(model, init_cond, input_range, ...
%       cp_array, phis, preds, TotSimTime, opt);

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA


function [results,inputs] = aristeo_multi_prop(model, init_cond, input_range, cp_array, phis, preds, TotSimTime,aristeo_options,timeout)

    global absreftime;
    global simtime;
    global aristeo_options_backup;
    global abstractedmodel;

    %% MULTI-SPEC: list of specifications and their predicates, timeout
    if nargin<9 || isempty(timeout)
        timeout=Inf;
    end
    if ~iscell(phis)
        phis={phis};
    end
    nspecs=numel(phis);
    if iscell(preds)
        if numel(preds)~=nspecs
            error('when preds is a cell array, it must contain one predicate array per specification');
        end
        specpreds=preds;
    else
        specpreds=repmat({preds},1,nspecs);
    end

    if (aristeo_options.n_refinement_rounds < 1)
        error('the number of refinement rounds n_refinement_rounds of the aristeo options should be grather than zero')
    end
    % Initialize output variables - Avoid growing variables in a loop
    results.run(aristeo_options.runs) = struct('bestRob',[],'nTests',[],'executiontime',[],'falsificationtime',[],'absreftime',[],'simtime',[],'searchTime',[],'checkTime',[]);
    results.phis=phis;
    inputs=num2cell(NaN(1,nspecs));
    %% Run tests
    aristeo_options_backup = aristeo_options;


    for ii=1:aristeo_options.nbr_Runs

            aristeo_options=aristeo_options_backup;
            executiontimetic = tic;
            results.run(ii).nTests = aristeo_options.optim_params.n_tests;
            results.run(ii).bestRob=realmax;
            results.run(ii).time = 0;
            results.run(ii).simtime = 0;
            results.run(ii).searchTime = 0;
            results.run(ii).checkTime = 0;
            input=NaN;
            t=1;
             aristeo_options.X0Fixed.idx_search=[];
             aristeo_options.X0Fixed.idx_search=[];
             if(aristeo_options.dispinfoaristeo==1)
                disp(strcat('################################### Run: ',num2str(ii)));
             end

           data=[];
           X0=[];
           results.run(ii).falsificationtime=zeros(1,aristeo_options.n_refinement_rounds);
           results.run(ii).absreftime=zeros(1,aristeo_options.n_refinement_rounds);
           results.run(ii).simtime=zeros(1,aristeo_options.n_refinement_rounds);
           results.run(ii).executiontime=zeros(1,aristeo_options.n_refinement_rounds);
           results.run(ii).searchTime=zeros(1,aristeo_options.n_refinement_rounds);
           results.run(ii).checkTime=zeros(1,aristeo_options.n_refinement_rounds);

           done=false;
           % searchTime: the total time required by the search for all the
           % iterations
           % checkTime: the total time required by the check for all the
           % iterations
           searchTime=0;
           checkTime=0;
           %% MULTI-SPEC: per-specification bookkeeping
           results.run(ii).bestRobs=realmax*ones(1,nspecs);
           results.run(ii).bestInputs=num2cell(NaN(1,nspecs));
           results.run(ii).falsified=false(1,nspecs);
           results.run(ii).falsifiedAtTest=NaN(1,nspecs);
           results.run(ii).falsifiedAtTime=NaN(1,nspecs);
           results.run(ii).selectedSpec=zeros(1,aristeo_options.n_refinement_rounds);
           results.run(ii).absrefAction=cell(1,aristeo_options.n_refinement_rounds);
           results.run(ii).timedOut=false;
           %% FIRST CHECK
           checktic=tic;
           [sigData,hs,robustness,simtime]=firstcheck(model,init_cond,phis{1},specpreds{1},TotSimTime, input_range, cp_array, aristeo_options);
           %% MULTI-SPEC: evaluate every specification on the initial trace
           robs=NaN(1,nspecs);
           robs(1)=robustness;
           for k=2:nspecs
               robs(k)=dp_taliro(phis{k}, specpreds{k}, hs.YT, hs.T);
           end
           checkTime=checkTime+toc(checktic);
           for k=1:nspecs
               results.run(ii).bestRobs(k)=robs(k);
               results.run(ii).bestInputs{k}=sigData;
               % same criterion as the original initial check
               if robs(k)<=0
                   results.run(ii).falsified(k)=true;
                   results.run(ii).falsifiedAtTest(k)=1;
                   results.run(ii).falsifiedAtTime(k)=toc(executiontimetic);
               end
           end
           remaining=find(~results.run(ii).falsified);
           if isempty(remaining)
               disp('Falsified by initial sample!');
           else


               while ((t<=aristeo_options.n_refinement_rounds) && ~isempty(remaining) && toc(executiontimetic)<timeout)

                   aristeo_options=aristeo_options_backup;
                   results.run(ii).simtime(t)=0;
                   %% MULTI-SPEC: select the first specification not yet falsified
                   cur=remaining(1);
                   phi=phis{cur};
                   preds=specpreds{cur};
                   results.run(ii).selectedSpec(t)=cur;

                    if(aristeo_options.dispinfoaristeo==1)
                            disp(strcat('RR ==> ',num2str(t)));
                    end

                    searchtic=tic;
                    % if aristeo is entering the 1st iteration of the loop
                    % OR the abstraction of the model was not succesfull in
                    % the previous iteration
                    % => execute the abstraction
                    % Otherwise, execute the refinement
                    if (t==1 || ~done)
                        %% ABSTRACTION
                        [data, abstractedmodel,X0, idOptions]=abstract(model,init_cond,input_range,cp_array,TotSimTime,sigData,hs,aristeo_options);
                        done=true;
                        results.run(ii).absrefAction{t}='abstract';
                    else
                        %% REFINEMENT
                        [data, abstractedmodel]=refine(data, abstractedmodel,aristeo_options, idOptions);
                        results.run(ii).absrefAction{t}='refine';
                    end


                    results.run(ii).absreftime(t)=results.run(ii).absreftime(t)+absreftime;
                    results.run(ii).simtime(t)=results.run(ii).simtime(t)+simtime;

                    aristeo_options.X0Fixed.fixed=1;
                    aristeo_options.X0Fixed.idx_fixed=1:1:size(X0,1);
                    aristeo_options.X0Fixed.values=X0;
                    aristeo_options.falsification=0;
                    tmpinfo=aristeo_options.dispinfo;
                    aristeo_options.dispinfo=0;
                    falsificationtimetic=tic;
                    aristeo_options=aristeo_options_backup;
                    %% FALSIFICATION
                   [input,surrogaterobustness,X0,UPoint,done]=falsification(abstractedmodel,init_cond, input_range, cp_array, phi, preds, TotSimTime,done,aristeo_options);

                    searchTime=searchTime+toc(searchtic);

                    results.run(ii).falsificationtime(t)=toc(falsificationtimetic);
                    aristeo_options.dispinfo=tmpinfo;

                    if(aristeo_options.dispinfoaristeo==1)
                        disp(strcat("Surrogate Robustness ==> ",num2str(surrogaterobustness)));
                    end
                    checktic=tic;
                    %% CHECK
                    [data,inputb,actualrob,Tsim,YTsim]=check(model,cp_array,input_range,init_cond,X0,input,UPoint,phi, preds,data, TotSimTime, aristeo_options);
                    %% MULTI-SPEC: evaluate the other remaining specifications on the same trace
                    robs=NaN(1,nspecs);
                    robs(cur)=actualrob;
                    for k=remaining
                        if k~=cur
                            robs(k)=dp_taliro(phis{k}, specpreds{k}, YTsim, Tsim);
                        end
                    end
                    checkTime=checkTime+toc(checktic);

                    results.run(ii).simtime(t)=results.run(ii).simtime(t)+simtime;

                    if(aristeo_options.dispinfoaristeo==1)
                        disp(strcat("Actual Robustness ==> ",num2str(actualrob)));
                    end

                    if(actualrob<results.run(ii).bestRob)
                        results.run(ii).bestInput=inputb;
                        results.run(ii).bestRob=actualrob;
                    end
                    %% MULTI-SPEC: record per-specification results and violations
                    for k=remaining
                        if(robs(k)<results.run(ii).bestRobs(k))
                            results.run(ii).bestInputs{k}=inputb;
                            results.run(ii).bestRobs(k)=robs(k);
                        end
                        % same criterion as the original loop condition
                        if ((aristeo_options.fals_at_zero==1 && robs(k)<=0)||(aristeo_options.fals_at_zero==0 && robs(k)<0))
                            results.run(ii).falsified(k)=true;
                            results.run(ii).falsifiedAtTest(k)=t+1;
                            results.run(ii).falsifiedAtTime(k)=toc(executiontimetic);
                        end
                    end
                    remaining=find(~results.run(ii).falsified);
                    t=t+1;
               end
           end
            results.run(ii).searchTime=searchTime;
            results.run(ii).checkTime=checkTime;
            results.run(ii).nTests = t;
            results.run(ii).timedOut = ~all(results.run(ii).falsified) && t<=aristeo_options.n_refinement_rounds;
            results.run(ii).executiontime = toc(executiontimetic);

    end
    %% MULTI-SPEC: falsifying input of each specification (first run that falsified it)
    for k=1:nspecs
        for ii=1:aristeo_options_backup.nbr_Runs
            if results.run(ii).falsified(k)
                inputs{k}=results.run(ii).bestInputs{k};
                break;
            end
        end
    end
end
