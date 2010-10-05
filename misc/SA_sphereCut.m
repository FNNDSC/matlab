function [s] = SA_sphereCut(R)
%
% ARGS
%   R       in      radius of sphere
%
% DESC
%   Determine the Surface Area of sphere of radius
%   R, cut such that a spherical segement of length R is 
%   removed
%

x2  = R*(1-sin(pi/3));
s = 4*pi*R^2 - pi*(1/4*R^2+x2^2);
