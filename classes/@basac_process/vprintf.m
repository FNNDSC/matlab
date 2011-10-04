function c = vprintf(c, alevel, astr_sprintf, varargin)
%
% NAME
%
%  function c = vprintf(c, alevel, astr_sprintf, varargin)
%
% ARGUMENTS
% INPUT
%	c		class		cortical parellation class
%	alevel		int		verbosity level threshold
%	astr_sprintf	string		formatted string typically
%					created with sprintf
%
% OPTIONAL
%	
%
% DESCRIPTION
%
%	This function method prints the <astr_sprintf> only if <alevel>
%	is less than or equal to the class internal member, m_verbosity.
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

c.mstack_proc 	= push(c.mstack_proc, 'vprintf');

LC		= c.m_marginLeft;
RC		= c.m_marginRight;

if(alevel <= c.m_verbosity)
    fprintf(1, astr_sprintf); 
%      pause(0.1);		% flush to command window
end

[c.mstack_proc, element]= pop(c.mstack_proc);
