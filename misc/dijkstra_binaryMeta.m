function c = dijkstra_binaryMeta(varargin)
%
% NAME
%
%	function c = dijkstra_binaryMeta([topLevelDir], [verbosity])
%
% ARGUMENTS
%
%	topLevelDir	in (string)	the "root" node from which
%					to recursively find and 
%					process all directories containing
%					'isoLabel.dsh'. If not specified,
%					this defaults to the current working
%					directory, './'
%	verbosity	in (int)	verbosity level. If not specified, 
%					defaults to 0. If specified, then
%					topLevelDir must also be spec'd.
%
%
%	c		out (int)	number of optimisations processed.
%					Zero if some error has occurred.
%
% DESCRIPTION
%
%	'dijkstra_binaryMeta' searches for all directories from <topLevelDir> 
%	that contain a file called 'options.txt'. In each of these directories,
%	a binary-search optimisation is performed.
%
% PRECONDITIONS
%
%	o The parent MatLAB process must be run from the nmr-std-env 
%	  environment ('nse' for bash) -- this is for running 
%	  'dijkstra_p1'.
%
%	o The directory tree under <topLevelDir> should have been created with
%	  'sapex_setup.bash' 
%
%	o Assumes a UNIX/Linux runtime.
%
% POSTCONDITIONS
%
%	o In each directory that contains 'isoLabel.dsh', a binary search
%	  optimisation experiment is performed.
%
%
% HISTORY
% 08 August 2005
% o Initial design and coding (large portions, particularly the loop logic
%   adapted from 'b2img.m').
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

	function str_alpha = squash(str_in)
		str_squashCMD 	= sprintf('echo %s|sed "s| ||g"|sed "s|\\[||"|sed "s|\\]||"', ...
						str_in);
		[ret str_alpha]	= unix(str_squashCMD);
	end

	function m_Xmin = X_sort(m_X)
		%
		% PRECONDITIONS
		% o m_X, an unsorted matrix of weight vectors and fitness.
	 	% o Assumes that the fitness value is in column 9.
		%
		% POSTCONDITIONS
		% o m_Xmin, the minimum fitness and weights of m_X. If 
		%   several weights have this minimum, return a matrix
		%   of these weights, otherwise a vector of the minimum
		%   only.
		%
		m_Xc	= m_X;
		m_Xcs	= sortrows(m_Xc, 9);
		v_fs	= m_Xcs(:, 9);
		m_Xmin	= m_Xcs(1:sum(v_fs==v_fs(1)), :);
	end

	function minWGHT_process(str_labelFileName, m_X, f_min)
		%
		% PRECONDITIONS
		% o m_X, a vector of weights with objective f_min
		% o m_X might contain multiple weight strings with
		%   same f_min
		%
		% POSTCONDITIONS
		% o For each row of duplicate minimum f_min, call
		%   min_binaryWGHT_create
		%

		[rows cols] = size(m_X);
		for row=1:rows
			v_X = m_X(row, 1:8);
			minWGHT_appendFile(str_labelFileName, v_X, f_min);
		end
	end

	function minWGHT_appendFile(str_labelFileName, v_X, f_min)
		str_XminMat	= mat2str(v_X);
		str_XminRet	= squash(str_XminMat);
		str_txtFile	= './min_binaryWGHT.txt';
		[str_Xmin, r]	= strtok(str_XminRet, char(10));
		str_minBinaryWGHT = ...
		sprintf('min_binaryWGHT_create.bash -r %s -w %s -f %f -t %s', ...
						str_labelFileName,	...
						str_Xmin,		...
						f_min,			...
						str_txtFile);
		[status result]		= unix(str_minBinaryWGHT, '-echo');
	end

%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 

tic
c 			= 0;	% final return value
topLevelDir		= './';
startDir		= cd;
verbosity		= 0;
f_min			= 0.0;
str_Xmin		= '00000000';
ret			= 0;

if length(varargin)
	topLevelDir	= varargin{1};
	if length(varargin) == 2
		verbosity   = varargin{2};
	end
end

%	
% Search for all directories that contain experiments to run
%	by tagging all 'isoLabel.dsh' files below topLevelDir
cd(topLevelDir);
str_target		= 'isoLabel.dsh';	% The target search file. All
						% directories containing this 
						% file are flagged for further
						% processing
str_findCMD		= sprintf('find $(pwd) -name %s', str_target);
[ret str_targetFiles]	= system(str_findCMD);
if ~sum(size(str_targetFiles))
	fprintf(1, 'No %s files were found!\nSearch directory: %s\n', str_target, topLevelDir);
	fprintf(1, '\tReturning to MatLAB with return value 0.\n\n');
	return;
end
[str_expDir str_rem]	= strtok(str_targetFiles, char(10));

%
% Pop back to the "startDir" to run dsh and capture relevant log
%	information
cd(startDir);
vprintf(1, 'Spawning dsh...');
str_dirpart		= fileparts(str_expDir);
str_optionsFile		= [str_dirpart, '/options.txt'];
str_initOptions		= sprintf('cp %s .', str_optionsFile);
[status, ret]		= unix(str_initOptions);
if ret
	error_exit('copying initial options.txt', 'cp returned non-zero', ret);
end
str_dsh = sprintf('dsh -c "NOP"');
[ret str_console] = unix(str_dsh, '-echo');
vprintf(1, '\t\t\t\t\t\t\t[ ok ]\n');
cd(topLevelDir);

%
% Process each directory that contains 'isoLabel.dsh'
%
str_pathStart		= cd;
errcount		= 0;
while length(str_rem)
	cd(str_pathStart);
	c		= c+1;
	i 		= findstr(str_target, str_expDir);
	str_thisExpDir	= str_expDir(1:i-1);
	cd(str_thisExpDir);
	vprintf(2, ...
	    sprintf('\nEntering directory %s\n', str_thisExpDir));
	str_sulcus		= basename(str_thisExpDir);
	vprintf(1, ...
		sprintf('Target sulcus...\t\t\t\t\t\t[ %s ]\n', str_sulcus));
	str_labelFileName	= [ str_sulcus '-1.label'];
	vprintf(1, ...
		sprintf('Source sulcus...\t\t\t\t\t\t[ %s ]\n', str_labelFileName));
	vprintf(1, 'Optimising...');
	% label filenames must be spec'd in absolute form!
	str_initDir		= cd;
	str_dshCWD		= sprintf('dsh -c "CWD %s; LISTEN"', str_initDir);
	str_labelFileName	= [ str_initDir, '/', str_labelFileName ];
	[ret str_console] 	= unix(str_dshCWD);
	[m_XminMat,f_min,m_X,errcount] 	...
				= dijkstra_binarySearch(str_labelFileName, verbosity, c);
	save('weightSpace.mat', 'm_X', '-ascii',  '-tabs');
	m_Xmin			= X_sort(m_X);
	if f_min ~= m_Xmin(1, 9)
		error_exit('checking returned min against searched min', ...
			   'mismatch detected.', '2');	
	end
	minWGHT_process(str_labelFileName, m_Xmin, f_min);
	vprintf(1, '\t[ ok ]\n');
	[ret str_console]	= unix('mv isoLabel.dsh isoLabel.done.dsh');
	[str_expDir str_rem] 	= strtok(str_rem, char(10));
end
cd(startDir);

if errcount
	fprintf(1, '%d errors in were trapped and resolved.\n', errcount);
end

vprintf(1, 'Terminating dsh...');
str_dshEnd = sprintf('dsh -c "NOP" -t 2>/dev/null');
[ret str_console] = unix(str_dshEnd);
vprintf(1, '\t\t\t\t\t\t[ ok ]\n');

toc
end

