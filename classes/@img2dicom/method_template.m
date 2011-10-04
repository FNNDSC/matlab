function [] = name(c, <>)
%
% NAME
%
%	function [] = name(c, <>)
%
% ARGUMENTS
% INPUT
%	c		class		cortical parellation class
%
% OPTIONAL
%	
%
% DESCRIPTION
%
%
% PRECONDITIONS
%
%
% POSTCONDITIONS
%
% NOTE:
%
% HISTORY
% 18 September 2007
% o Initial design and coding.
%

c.mstack_proc 	= push(c.mstack_proc, 'planeIndex_get');

[c.mstack_proc, element]= pop(c.mstack_proc);
