function [radians] = toRadians(degrees)
%
% ARGS
%   degrees         in      degree argument
%   radians         out     radian equivalent of degrees
%
% DESC
%   Simply converts the given degree value to radians.
%
% HISTORY
% 25 July 2002
%   o Initial design and coding.
%

radians = degrees * pi / 180;
