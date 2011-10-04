function []	= sys_print(ac, astr, varargin)
%
% NAME
%
%	function []	= sys_print(ac, astr, <verbosityLevel>)
%
% ARGUMENTS
% INPUT
%	ac			class		"standard" class
%	astr			string		text to print
%
% OPTIONAL INPUT
%	verbosityLevel		int		verbosity cut off level
%
% DESCRIPTION
%
% A simple wrapper to vprintf that uses syslog_prefix().
%
% PRECONDITIONS
%
%	o Assumes class <c> exists in current scope.
%	o Assumes class <c> has:
%		- vprintf
%		- RC / LC
%
% POSTCONDITIONS
%
% NOTE:
%
% HISTORY
% 11 April 2008
% o Initial design and coding.
%

RC	= ac.m_marginLeft;
LC	= ac.m_marginRight;

vlevel	= 1;

if length(varargin)
	vlevel	= varargin{1};
end

vprintf(ac, vlevel, sprintf('%s %s', syslog_prefix(), astr));
