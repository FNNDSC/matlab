function acell_dir = ls09(varargin)
%
% NAME
%
%	function acell_dir = ls09([astr_lsArgs])
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
%	'ls' is simply a thin wrapper around the system 'ls' function call
%	effectively runs an '/bin/ls -d [0-9]*', returning any directories
%	that start with alpha characters in a cell array..
%
% PRECONDITIONS
%
%	o UNIX runtime
% 
% SEE ALSO
%
% HISTORY
% 21 September 2007
% o Initial design and coding.
%

str_ls09		= '/bin/ls -d [0-9]*';
if length(varargin)
    cell_args		= cell(1, length(varargin));
	for argc	= 1:length(varargin)
	    str_arg	= varargin{argc};
	    str_ls09 	= sprintf('%s %s', str_ls09, str_arg);
	end
end

% First perform a sanity check on the passed args...
[status, str_dirAll]    = system(str_ls09);
if status
    return
end


str_ls09		= sprintf('%s | sort -n ', str_ls09);

[status, str_dirAll]	= system(str_ls09);
if status
    return
end

% Create a cell array of the directory names
ndir			= 1;
[str_dir str_rem]	= strtok(str_dirAll);
cell_dir{ndir}		= str_dir;
while length(str_rem)
    [str_dir str_rem]	= strtok(str_rem);
    ndir		= ndir + 1;
    cell_dir{ndir}	= str_dir;
end

for dir=1:ndir-1
    acell_dir{dir}	= cell_dir{dir};
end


