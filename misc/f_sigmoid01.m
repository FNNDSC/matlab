function [y] = f_sigmoid01(x, varargin)
%
% 	[y] = f_sigmoid01(x [a [,b]])
%
% ARGS
% INPUT
% 	x	scalar float		the x coordinate to evaluate
% 	
% OPTIONAL
% 	a	scalar float		"width factor" (default = 1)
% 	b	scalar float		"offset factor" (default = 0)
% 	
% OUTPUT
% 	y	scalar float		function lookup for given x, a, b
%
% DESC
% 	Performs a simple function call for a standard sigmoidal defined as:
% 	
% 		y = 1 / (1 + exp(ax+b))
%
% HISTORY
% 02 April 2009
% o Initial design and coding.
%

a	= 1.0;
b	= 0.0;

if length(varargin) >= 1;	a = varargin{1};	end
if length(varargin) >= 2;	b = varargin{2};	end

y = 1 / (1 + exp(a*x + b));
