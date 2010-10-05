function [count]	= curvs_delFind(	astr_origDir, 	...
						astr_fileExp, 	...
						astr_newDir, 	...
						varargin)
%
% NAME
%
%	function [count]	= curvs_delFind(	astr_origDir, 	...
%							astr_fileExp, 	...
%							astr_newDir	...
%							[, a_curvDC])
%
% ARGUMENTS
%    INPUTS
%	astr_origDir	string		a directory containing a series of 
%					numbered sub-dirs, each of which
%					houses principle curvature data
%	astr_fileExp	string		a simple regex string that defines
%					the list of actual curvature files in
%					each directory to process.
%	astr_newDir	string		the directory to contain the difference
%					curvature data.
%
%    OPTIONAL INPUTS 
%	a_curvDC	int 		the 'number' of the directory in
%					<astr_origDir> that contains the 
%					DC curvature. The curvature files
%					in this directory will be subtracted
%					from each of the directory curvatures
%					in <astr_origDir>.
%
%    OUTPUTS
%	count		int/bool	number of directories processed.
%
% DESCRIPTION
%
%	'curvs_delFind' was written to subtract the curvatures in the
%	DC directory, i.e. wavelet power 1, from all the other wavelet
%	powers.
%
%	Since the lowest wavelet power is analogous to the DC component
%	of a frequency signal, by subtracting this from the other powers
%	we remove the curvature of the actual brain "sphere" itself, i.e.
%	flatten the brain and restrict curvature analysis to secondary and
%	higher order folds.
%
% PRECONDITIONS
%
%	o <astr_origDir> must contain principle curvatures in directories
%	  numbered 1.. 7
%
% POSTCONDITIONS
%
%	o for each of the directories in <astr_newDir>, the curvatures in
%	  <astr_origDir>/<a_curvDC> are subtracted.
%	o no detailed error / sanity checking is performed!
%
% HISTORY
% 02 August 2006
% o Initial design and coding.
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

%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 

count		= 0;
curvDC		= 1;
if length(varargin)
	if length(varargin) >= 1
		DCwavelet = varargin{1};
		if ~isnumeric(bins)
		    error_exit('checking on <a_curvDC>',		...
			   '<a_curvDC> must be numeric',	...
			   '10');
		end
	end
end
str_curvDC	= num2str(curvDC);

% list all the subdirs in <astr_origDir>
startDir			= cd;
[status,str_dirAll]	= system(sprintf('cd %s >/dev/null; /bin/ls -d [0-9]*', astr_origDir));
str_start		= pwd;
[status, str_subjDir]	= system('echo $SUBJECTS_DIR');

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
for dir = 2:cols
	%str_dir		= num2str(a_dirAll(dir));
	cd(astr_origDir);
	str_dir		= cell_dir{dir};
	cd(str_dir);
	% Create a list of all the curvature files to be processed
	[ret str_curvList]	= system(sprintf('/bin/ls -1 %s', astr_fileExp));
	[str_curvFile str_rem]	= strtok(str_curvList, char(10));
	while length(str_rem)
		str_curvDCpath	= sprintf('%s/%s/%s', 		...
						astr_origDir,	...
						str_curvDC,	...
						str_curvFile);
		str_curvCurpath	= sprintf('%s/%s/%s', 		...
						astr_origDir,	...
						str_dir,	...
						str_curvFile);
		str_curvDelpath	= sprintf('%s/%s/%s', 		...
						astr_newDir,	...
						str_dir,	...
						str_curvFile);

		fprintf(1,'%23s - %-24s', 			...
		sprintf('%s/%s', str_dir,	str_curvFile),	...
		sprintf('(DC) %s/%s...',			...
				str_curvDC, 	str_curvFile 	...
				));
		[crvDC,  fnumDC]	= read_curv(str_curvDCpath);
		[crvDir, fnumDir]	= read_curv(str_curvCurpath);

		if fnumDC ~= fnumDir
			error_exit(	'reading curvature files',	...
					'vertex number mismatch found.',...
					'1');
		end

		crvDel		= crvDir - crvDC;
		write_curv(str_curvDelpath, crvDel, fnumDC);

		fprintf(1, '%30s\n', '[ ok ]');
		[str_curvFile str_rem]	= strtok(str_rem, char(10));
		count = count + 1;
	end
	cd(startDir);
end
	

end