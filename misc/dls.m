function acell_dir = dls(varargin)
%
% NAME
%
%	function acell_dir = dls([astr_lsArgs])
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
%	'dls' is simply a thin wrapper around the system 'ls' function call
%	that returns the ls contents in a cell.
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

str_gls         = '/opt/local/bin/gls';
str_ls          = '/bin/ls';

if exist(str_gls)
    str_ls              = str_gls;
end
if length(varargin)
    cell_args		= cell(1, length(varargin));
	for argc	= 1:length(varargin)
	    str_arg	= varargin{argc};
	    str_ls 	= sprintf('%s %s', str_ls, str_arg);
	end
end
% disp(str_ls);
[status, str_dirAll]	= system(str_ls);

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


