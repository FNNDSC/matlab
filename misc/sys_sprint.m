function [s] = sys_sprint(astr)
%
% NAME
%
%  function [s] = sys_sprint(astr)
%
% ARGUMENTS
% INPUT
%	astr	string		string to print
% OPTIONAL
%	
% OUTPUT
%	s	string		syslog-style prefixed string
%
% DESCRIPTION
%
%	This function prepends <astr> with syslog_prefix().
%
% PRECONDITIONS
%
% POSTCONDITIONS
%
% NOTE:
%
% HISTORY
% 12 December 2008
% o Initial design and coding.
%
s = sprintf('%s %s', syslog_prefix(), astr);
