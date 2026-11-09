function [fig, ax] = animinit(name)
% ANIMINIT Test-only stand-in for the Simulink demo helper animinit, which
% is no longer shipped with recent MATLAB releases (e.g. R2024b) but is
% called by the animation block of Tutorial/simgeneral/pendulum.slx.
% It only creates an invisible figure; it does not affect the simulation.
    fig = figure('Name', name, 'NumberTitle', 'off', 'Visible', 'off', 'HandleVisibility', 'callback');
    ax = axes('Parent', fig);
    hold(ax, 'on');
end
