function [acell_curv] = k1k2_batch(varargin)
%
% NAME
%
%  	function [acell_curv] = k1k2_batch[	astr_hemi='lh',
%						astr_outFileName])
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%	astr_hemi		string		hemisphere to process.
%	astr_outFileName	string		output curvature file name.
%
% OUTPUTS
%	acell_curv		cell		cell array of curvature vectors
%
% DESCRIPTION
%
%	'k1k2_batch' simply runs 'k1k2_createCurv' in each of the
%	"numeric" subdirectories branching from its working directory.
%
% PRECONDITIONS
%
% 	o A set of subdirectories, each with a name starting with a
%	  numerical character are processed.
%	o Each of these subdirectories *must* contain a 'K1' and 'K2'
%	  curvature file.
%
% POSTCONDITIONS
%
%	o Each valid subdirectory will be processed with 'k1k2_createCurv'.
%	  
%
% SEE ALSO
%
% 	o k1k2_createCurv.m
%
% EXAMPLE USAGE
%
%	[acell_curv] = k1k2_batch('rh', 'rh.smoothwm.SI');
%
% HISTORY
% 22 September 2006
% o Initial design and coding.
%
%

%%%%%%%%%%%%%% 
%%% Nested functions
%%%%%%%%%%%%%% 
	function error_exit(	str_action, str_msg, str_ret)
		fprintf(1, '\tFATAL:\n');
		fprintf(1, '\tSorry, some error has occurred.\n');
		fprintf(1, '\tWhile %s,\n', str_action);
		fprintf(1, '\t%s\n', str_msg);
		error(str_ret);
	end

	function vprintf(level, str_msg)
	    if verbosity >= level
		fprintf(1, str_msg);
	    end
	end

	function [F] = f(K1, K2)
	    F = abs(K1 .* K2) ./ (K1.^2  - K2.^2);
	end

%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 


str_hemi	= 'lh';
str_outFileName	= sprintf('%s.smoothwm.fK1K2', str_hemi);

if length(varargin)
	str_hemi	= varargin{1};
	str_outFileName	= sprintf('%s.smoothwm.fK1K2', str_hemi);
	if length(varargin) >= 2
		str_outFileName	= varargin{2};
	end
end

[status,str_dirAll]	= system('/bin/ls -d [0-9]* | sort -n');
str_start		= pwd;

% Create a cell array of the directory names
ndir			= 1;
[str_dir str_rem]	= strtok(str_dirAll);
cell_dir{ndir}		= str_dir;
while length(str_rem)
	[str_dir str_rem]	= strtok(str_rem);
	ndir			= ndir + 1;
	cell_dir{ndir}		= str_dir;
end

% Create string array from results - each directory will be a separate element:
cols			= ndir - 1;
acell_curv		= cell(1, cols);
for dir = 1:cols
	%str_dir		= num2str(a_dirAll(dir));
	cell_processedDir{dir}	= cell_dir{dir};
	str_dir			= cell_dir{dir};
	fprintf(1, sprintf('%40s', sprintf('Processing %s', str_dir)));
	cd(str_dir);
	[av_curv, ab_singularity] = k1k2_createCurv(str_hemi, str_outFileName);
	acell_curv{dir}		= av_curv;
	if ~ab_singularity
	    fprintf(1, sprintf('%40s\n', '[ ok ]'));
	else
	    fprintf(1, '\n');
	end
	cd(str_start);
end

end