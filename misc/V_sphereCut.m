function [v] = V_sphereCut(R)
%
% ARGS
%   R       in      radius of sphere
%
% DESC
%   Determine the Volume of sphere of radius
%   R, cut such that a spherical segement of length R is 
%   removed
%

x2  = R*(1-sin(pi/3));
v = 4/3*pi*R^3 - 1/6*pi*x2*(3/4*R^2+x2^2);