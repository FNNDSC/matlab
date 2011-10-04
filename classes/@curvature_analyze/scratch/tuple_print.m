function []	= tuple_print(ac, av_tuple, varargin)
%
% NAME
%
%	function []	= tuple_print(ac, astr_LC, av_tuple, <verbosityLevel>)
%
% ARGUMENTS
% INPUT
%	ac			class		"standard" class
%	astr_LC			string		text to print in left column
%	av_tuple		vector 		2 element vector to print in
%						right column
%
% OPTIONAL INPUT
%	verbosityLevel		int		verbosity cut off level
%
% DESCRIPTION
%
% Prints a two column output, left column <astr_LC>, right column containing
% the 1st two elements of <av_tuple>.
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

vprintf(ac, vlevel, sprintf('%*s', LC, astr_LC));
vprintf(ac, vlevel, sprintf('%*s\n', RC, sprintf('[ %d %d ]',         ...
                                av_tuple(1,1), av_tuple(1,2))));
