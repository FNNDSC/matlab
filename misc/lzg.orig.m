function [l, z, g] = lzg(a_histogram, varargin)
%
% NAME
%
%	function [l, z, g] = lzg(a_histogram [, ab_percent])
%
% ARGUMENTS
% INPUT
%	a_histogram		a histogram array
%	ab_percent		if specified, return l, z, g as
%				percentages of original array
%				length.
%
% OUTPUTS
%	l			count of elements less than zero
%	z			count of elements equal to zero
%	g			count of elemente greater than zero
%
% DESCRIPTION
%
%	'lzg' simply accepts an array and returns the number of
%	elements that are less than zero 'l', zero 'z', and 
%	greater than zero, 'g'.
%
% PRECONDITIONS
%
% 	o a_histogram must be *column* vector.
%
% SEE ALSO
%
% 	o curvs_plot.m
%
% HISTORY
% 09 January 2006
% o Initial design and coding.
%
%

[rows cols] = size(a_histogram);
if cols ~= 1
	error('1', 'input array must be a column vector.');
end

b_percent = 0;
if length(varargin)
	b_percent = varargin{1};
end

a_l = a_histogram(a_histogram <  0);
a_z = a_histogram(a_histogram == 0);
a_g = a_histogram(a_histogram >  0);

[l cols] = size(a_l);
[z cols] = size(a_z);
[g cols] = size(a_g);

if b_percent
	l = l / rows;
	z = z / rows;
	g = g / rows;
end