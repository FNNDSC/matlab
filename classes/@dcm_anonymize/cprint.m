function []	= cprint(ac, astr_LC, astr_RC, varargin)
%
% NAME
%
%	function []	= cprint(ac, astr_LC, astr_RC, <verbosityLevel>)
%
% ARGUMENTS
% INPUT
%	ac			class		"standard" class
%	astr_LC			string		text to print in left column
%	astr_RC			string		text to print in right column
%
% OPTIONAL INPUT
%	verbosityLevel		int		verbosity cut off level
%
% DESCRIPTION
%
% Prints a two column output, left column <astr_LC>, right column <astr_RC>.
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

LC	= ac.m_marginLeft;
RC	= ac.m_marginRight;

vlevel	= 1;

if length(varargin)
	vlevel	= varargin{1};
end

vprintf(ac, vlevel, sprintf('%*s', LC, astr_LC));
vprintf(ac, vlevel, sprintf('%*s\n', RC, sprintf('%s', astr_RC)));

