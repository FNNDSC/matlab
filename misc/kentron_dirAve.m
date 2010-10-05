function count = kentron_dirAve(varargin)
% NAME
%
%	function ret = kentron_dirAve(	[astr_dir,
%					 astr_stem])
%
% ARGUMENTS
% inputs - optional
%	astr_dir	string		directory containing the per-direction
%					repacked kentron volumes
%	astr_stem	string		filename stem for the repacked volumes
%
% outputs
%	count		int		number of volumes processed
%
% DESCRIPTION
%
%
% PRECONDITIONS
%
%
% POSTCONDITIONS
%
%
% SEE ALSO
%
%
% HISTORY
%
% 20 July 2006
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

str_dir		= './';
str_stem	= 'f';

if length(varargin)
	str_dir	= varargin{1};
	if length(varargin) == 2
	    str_stem	= varargin{2};
	end
end

count		= 0;
totalDirections	= 6;
cell_dirAve	= cell(1, totalDirections);
for dir = 1:totalDirections
    cell_vol	= cell(1, 10);
    j		= 1;
    for i = dir:7:70
	str_fileName				= sprintf('f_%03d.mgh', i);
	str_msg	= sprintf('(dir %d): Reading %s to cell index %d...', ...
				dir, str_fileName, j);
	count 	= count + 1;
	fprintf(1, '%55s', str_msg)
	[cell_vol{j}, M_vox2ras, v_mrParms] 	= load_mgh2(str_fileName);
	j 					= j + 1;
	fprintf(1, '%25s\n', '[ ok ]');
    end

    [rows cols slices]	= size(cell_vol{1});
    str_msg 	= sprintf('(dir %d): Averaging...', dir);
    fprintf(1, '%55s', str_msg);
    V_sum		= zeros(rows, cols, slices);
    for i = 1:10
	V_sum		= V_sum + cell_vol{i};
    end
    cell_dirAve{dir}	= V_sum ./ 10;
    fprintf(1, '%25s\n', '[ ok ]');
    str_outputName	= sprintf('f_ave.%d.mgh', dir);	
    str_msg	= sprintf('(dir %d): Saving MGH format: %s...', ...
			dir, str_outputName);
    fprintf(1, '%55s', str_msg);
    save_mgh(cell_dirAve{dir}, str_outputName, M_vox2ras, v_mrParms);
    fprintf(1, '%25s\n', '[ ok ]');
end

V_sum		= zeros(rows, cols, slices);
V_smoothed	= zeros(rows, cols, slices);
j		= 0;
for dir=1:totalDirections-1
    V_sum	= V_sum + cell_dirAve{dir};     
    j		= j + 1;
end
V_smoothed 	= V_sum ./ j;

str_outputName	= sprintf('f_ave.1-5.mgh');	
str_msg		= sprintf('Saving MGH format: %s...', str_outputName);
fprintf(1, '%55s', str_msg);
save_mgh(V_smoothed, str_outputName, M_vox2ras, v_mrParms);
fprintf(1, '%25s\n', '[ ok ]');

end
