function [T, XT, YT, LT, CLG, GRD] = lag_sut(X0, simT, TU, U) %#ok<INUSL>
% LAG_SUT Deterministic black-box SUT for tests: discrete first-order lag
%   y(k) = 0.5*y(k-1) + 0.5*u(k-1),  y(0) = 0  (one sample per element of TU)
% With a constant input u, y moves monotonically from 0 towards u, so
% y > c is reachable iff u > c.
    T = TU;
    YT = filter([0 0.5], [1 -0.5], U(:,1));
    XT = YT;
    LT = [];
    CLG = [];
    GRD = [];
end
