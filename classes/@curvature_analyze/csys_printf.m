function []	= csys_printf(ac, varargin)
%
% NAME
%
%	function []	= csys_print(ac, format ...)
%
% ARGUMENTS
% INPUT
%	ac			class		"standard" class
%	format, ...             string          C-style format string
%
% DESCRIPTION
%
% A simple wrapper to sys_printf(...)
%
% PRECONDITIONS
%
%	o Assumes class <c> exists in current scope.
%		- RC / LC
%
% POSTCONDITIONS
%
% NOTE:
%
% HISTORY
% 18 September 2009
% o Initial design and coding.
%

RC	= ac.m_RC;
LC	= ac.m_LC;

if ac.m_verbosity >= ac.m_verbosityLevel, sys_printf(varargin{:}); end
