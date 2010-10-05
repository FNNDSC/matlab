function [V] = vol_normalizeSlice(a_V, varargin)
%
% [V] = vol_normalizeSlice(a_V [, lowerBound [, upperBound]])
%
% ARGS
% INPUT
% a_V                   vol                     volume data to normalize
% lowerBound            opt			lower bound of slice result
% upperBound		opt			upper bound of slice result
% 
% DESC
% Recast all slices in input data to fall between lowerBound and
% upperBound, typically between 0 and 1. Normalization is performed
% on a slice-by-slice basis.
% 
% HISTORY
% 04 December 2008
% o Initial design and coding.
%

f_lb	= 0.0;
f_ub	= 1.0;

if length(varargin)
	f_lb	= varargin{1};
	if length(varargin>=2)
	   f_up	= varargin{2};
	end
end

V       = a_V;
sz      = size(V);

for slice   = 1:sz(3)
    V(:,:,slice)    = normalize(a_V(:,:,slice), f_lb, f_ub);
end
