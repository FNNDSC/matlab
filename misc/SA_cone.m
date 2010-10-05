function [s] = SA_cone(R, x1)
%
% ARGS
%   R       in      diameter of base
%   x1      in      height of cone
%
% DESC
%   Determine the Surface Area of cone with
%   given dimensions
%

s = 1/2*pi*R*(1/4*R^2+x1^2)^0.5;

