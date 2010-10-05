function [s] = V_cone(R, x1)
%
% ARGS
%   R       in      diameter of base
%   x1      in      height of cone
%
% DESC
%   Determine the Volume of a cone with
%   given dimensions
%

s = 1/3*pi*1/4*R^2*x1;
