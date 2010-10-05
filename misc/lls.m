function [] = lls(varargin)
%
% NAME
%
%	function [] = lls([*astr_lsArgs])
%
% ARGUMENTS
%
%	INPUT
%	astr_lsArgs	string (optional)	a string denoting additional
%						arguments to a command line
%						'ls'.
%
% DESCRIPTION
%
%	'lls' is simply a thin wrapper around the system 'ls' function call
%	that mimicks the 'alias'ing ability of most shells.
%
% PRECONDITIONS
%
%	o UNIX runtime
% 
% SEE ALSO
%
% HISTORY
% 17 July 2006
% o Initial design and coding.
%

str_ls	= 'ls -CFG --color ';
if length(varargin)
	cell_args	= cell(1, length(varargin));
	for argc	= 1:length(varargin)
		str_arg	= varargin{argc};
		str_ls 	= sprintf('%s %s', str_ls, str_arg);
	end
end

system(str_ls);