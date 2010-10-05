function [M_grayT, M_whiteT, M_grayTperc, M_whiteTperc,	M_gray, M_white] ...
						= mri_volStats(varargin)
%
% NAME
%
%  function [M_grayT, M_whiteT, M_grayTperc, M_whiteTperc, M_gray, M_white] ...
%  						= mri_volStats(varargin)
%
%
% ARGUMENTS
%    INPUTS
%	astr_suffix	string		a string that is appended to the text
%					'white' and 'gray'. This defines the
%					text files that contain white- and
%					gray- volume data.
%
%    OUTPUTS
%	M_grayT		matrix		Gray volume data - total.
%	M_whiteT	matrix		White volume data - total.
%	M_grayTperc	matrix		Percentage of total volume that is gray.
%	M_whiteTperc	matrix		Percentage of total volume that is white.
%	M_gray		matrix		All data for gray.
%	M_white		matrix		All data for white.
%
% DESCRIPTION
%
%	'mri_volStats' depends on the output from 'mri_volprocess_postproc.bash'
%	and returns the contents of the 'grayVolumes.txt' and 'whiteVolumes.txt'
%	files.
%
%	Some simple processing is also returned in the gray- and white- percentage
%	matrices.
%
% PRECONDITIONS
%
%	o Output from 'mri_volprocess_postproc.bash'.
%
% POSTCONDITIONS
%
%	o File data is read into MatLAB; some simple processing is also performed.
%
%
% HISTORY
% 06 June 2006
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

str_suffix		= 'Volumes.txt';
if length(varargin)
	str_suffix	= varargin{1};
end

str_gray		= [ 'gray' str_suffix];
str_white		= [ 'white' str_suffix];	

M_gray			= load(str_gray,  '-ascii');
M_gray			= M_gray(:, 2:5);
M_grayLeft		= M_gray(:, 1);
M_grayRight		= M_gray(:, 2);
M_grayTotal		= M_gray(:, 3);
M_grayAve		= M_gray(:, 4);

M_white			= load(str_white, '-ascii');
M_white			= M_white(:, 2:5);
M_whiteLeft		= M_white(:, 1);
M_whiteRight		= M_white(:, 2);
M_whiteTotal		= M_white(:, 3);
M_whiteAve		= M_white(:, 4);

M_wholeLeft		= M_grayLeft 	+ M_whiteLeft;
M_wholeRigtht		= M_grayRight	+ M_whiteRight;
M_wholeTotal		= M_grayTotal	+ M_whiteTotal;

M_grayT			= M_grayTotal;
M_whiteT		= M_whiteTotal;
M_grayTperc		= M_grayT  ./ M_wholeTotal;
M_whiteTperc		= M_whiteT ./ M_wholeTotal;

end