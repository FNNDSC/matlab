function C = vprintf(C, alevel, varargin)
%
% NAME
%
%  function C = vprintf(C, alevel, format, ...)
%
% ARGUMENTS
% INPUT
%	C		class		class that contains a verbosity value
%	alevel		int		verbosity level threshold
%	format		string		C-style formatted string
%
% OPTIONAL
%	
%
% DESCRIPTION
%
%	This function method prints iff the passed <alevel> <= verbosity
%
% PRECONDITIONS
%
%
% POSTCONDITIONS
%
% NOTE:
%
% HISTORY
% 18 September 2009 
% o Initial design and coding.
%

C.mstack_proc 	= push(C.mstack_proc, 'vprintf');

sfrmt		= sprintf(varargin{:});
if(alevel <= C.m_verbosity), fprintf(1, '%s', sfrmt); end

[C.mstack_proc, element]= pop(C.mstack_proc);
