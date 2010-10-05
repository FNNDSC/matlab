function [x] = rms(a_X)
%
% NAME
%
%	function [x] = rms(a_X)
%
% ARGUMENTS
% INPUT
%	a_X			a matrix (or vector)
%
% OUTPUTS
%	x			rms of all elements in a_X
%
% DESCRIPTION
%
%	'rms' calculates a simple root mean square on its
%	input argument. This is straightforward:
%  
%  		x =  sqrt(1/N sum(1..N, a_Xi^2))
%
% PRECONDITIONS
%
% 	o a_X is a matrix / vector.
%
% POSTCONDITIONS
%
%	o a scalar (x) is returned.
%
% HISTORY
% 01 June 2006
% o Initial design and coding.
%
%

[rows cols] 	= size(a_X);
N		= rows * cols;

S		= sum(sum(a_X.^2));
x		= sqrt(S/N);

