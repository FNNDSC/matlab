function [V] = normalize(a_V, varargin)
%
% [V] = normalize(a_V [, lowerBound [, upperBound]])
%
% ARGS
% INPUT
% a_V			vector, matrix, or vol	data to normalize
% lowerBound		opt			lower bound of result
% upperBound		opt			upper bound of result
% 
% DESC
% Recast all values in input data to fall between lowerBound and
% upperBound, typically between 0 and 1.
% 
% The mean of the resultant is the old mean scaled by the range
% of (upperBound - lowerBound)/(f_max - f_min) -- assuming that a_V
% is positive definite.
%
% NOTE
% o If the input data has no deviation, then the normalized result
%   will be zero.
%
% HISTORY
% 04 December 2008
% o Initial design and coding.
%

f_lb	= 0.0;
f_ub	= 1.0;
f_min	= 0.0;
f_max	= 1.0;
V	= a_V;

if length(varargin)
	f_lb	= varargin{1};
	if length(varargin)>=2
	   f_up	= varargin{2};
	end
end

sz	= size(a_V);

if length(sz) == 3
	f_max	= max(max(max(a_V)));
	f_min	= min(min(min(a_V)));
else 
  if length(sz) == 2
    if sz(1) == 1 || sz(2) == 1
	f_max	= max(a_V);
	f_min	= min(a_V);
    else
	f_max	= max(max(a_V));
	f_min	= min(min(a_V));
    end
  end
end

f_rangeNew	= f_ub  - f_lb;
f_rangeOrig	= f_max	- f_min;

V	= V - f_min;
if(f_rangeOrig)
    V	= V ./ f_rangeOrig;
end
V	= V .* f_rangeNew;
V	= V + f_lb;
