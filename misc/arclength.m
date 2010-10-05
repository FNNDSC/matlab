function [L] = arclength(R)
%
% NAME
%
%       function [L] = arclength(R)
%
% ARGUMENTS
% INPUT
%	R			vector 		radius vector
%
% OPTIONAL
%
% OUTPUTS
%       L			vector		arclength of radius over a 1mm
%						arc.
%
% DESCRIPTION
%
%       'arclength' returns the arclength of the given radius 
%	vector over a 1mm arc.
%
% PRECONDITIONS
%
% POSTCONDITIONS
%
%       o arclength is returned.
%
% SEE ALSO
%
% HISTORY
% 17 January 2007
% o Initial design and coding.
%

L = atan(1./R).*R;
