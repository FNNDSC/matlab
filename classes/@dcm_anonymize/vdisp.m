function c = vdisp(c, alevel, aM, varargin)
%
% NAME
%
%  function c = vdisp(c, alevel, aM, varargin)
%
% ARGUMENTS
% INPUT
%	c		class		cortical parellation class
%	alevel		int		verbosity level threshold
%	aM		matrix		Matrix to 'disp'
%
% OPTIONAL
%	
%
% DESCRIPTION
%
%	This function method conditionally does a disp(aM)
%	based on <alevel> and the class internal verbosity.
%
% PRECONDITIONS
%
%
% POSTCONDITIONS
%
% NOTE:
%
% HISTORY
% 10 July 2007
% o Initial design and coding.
%

c.mstack_proc 	= push(c.mstack_proc, 'vdisp');

LC		= c.m_marginLeft;
RC		= c.m_marginRight;

if(alevel <= c.m_verbosity)
    disp(aM);
end

[c.mstack_proc, element]= pop(c.mstack_proc);
