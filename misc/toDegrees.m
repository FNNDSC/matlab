function [degrees] = toDegrees(radians)
%
% ARGS
%   radians         in      radian argument
%   degrees         out     degree equivalent of radians
%
% DESC
%   Simply converts the given radian value to degrees.
%
% HISTORY
% 25 July 2002
%   o Initial design and coding.
%

degrees = 180 * radians / pi;

