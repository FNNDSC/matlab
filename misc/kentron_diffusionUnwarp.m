function ret = kentron_diffusionUnwarp(	str_measDir, 	...
					str_dicomDir,	...
					varargin)
% NAME
%
%  function ret = kentron_diffusionUnwarp(	measDir, 	...
%  						dicomDir)
%
% ARGUMENTS
% inputs
%	astr_measDir	string		The "root" directory containing Siemens
%					sequence scanner generated raw data
%					files 'meas.{asc,out}'.
%	astr_dicomDir	string		The "root" directory containing Siemens
%					generated DiCOMS corresponding to the
%					same run as the measDir.
%
% optional
%	as_kentron	struct		An optional structure conforming
%					to 'kentron_struct(...)' that
%					contains additional parameters
%					used mostly to specify output files and
%					default 'epidewarp.fsl' parameters.
% outputs
%	ret		out (int)	Zero if no error has occurred
%					One if some error has occurred.
%
% DESCRIPTION
%
%	'kentron_diffusionUnwarp' is a MatLAB script function that
%	controls several bash-coded shell scripts that taken together
%	perform a B0 field correction on a set of kentron study diffusion
%	data scans.
%	
%	Most of the "heavy lifting" is done by various FreeSurfer and related
%	processes, including 'mri_convert' on the FreeSurfer side and
%	'epidewarp.fsl' - a FreeSurfer bundled front end to FSL's FUGUE and
%	PRELUDE.
%
%	This heterogeneous family of MatLAB functions and shell scripts sets
%	connective plumbing that controls and directs the flow of information 
%	between the various data / file types.
%
%	One of the main input parameters to 'epidewarp.fsl' is the phase
%	difference between successive echoes. This difference is most easily
%	determined in MatLAB, hence the kentron diffusion unwarp stream is
%	MatLAB based.
%
% PRECONDITIONS
%
%	o The parent MatLAB process must be run from the nmr-std-env 
%	  environment ('nse' for bash) -- this is for running 
%	  'mri_convert' and 'epidewarp.fsl'.
%
%	o Assumes a UNIX/Linux runtime.
%
%	o Use kentron_struct(...) for additional function arguments.
%
%	o Make sure that the following shell scripts are on the system path:
%
%		kentron_seqrecon.bash
%		kentron_dicomProcess.bash
%
% POSTCONDITIONS
%
%	o For the given diffusion sequence DiCOMS in <astr_dicomDir> and the
%	  raw data meta-FID map in <astr_measDir>, the final output of this
%	  processing stream is a B0-field corrected EPI diffusion sequence.
%
%	o If no errors have occured, the script returns zero (0), else an
%	  error text string.
%
% SEE ALSO
%
%	o 'kentron_seqrecon.bash'	
%	   Reconstructs the multi-echo 2D raw data sequence that is used to
%	   determine the FID map.
%	o 'kentron_dicomProcess.bash'	
%	   Creates a 4D Analyze format volume as well as an example volume.
%	o 'kentron_struct.m'
%	   Structure housing additional optional parameters.
%
% HISTORY
%
% 21 June 2006
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



global str_functionName;
str_functionName	= 'motl2cor';

str_colorFileDir	= '';
str_brainMRItr		= '';
str_wmMRItr		= '';
str_filledMRItr		= '';

% Check for color struct
if length(varargin)
	s_otlColor	= varargin{1};
	if ~isstruct(s_otlColor)
		error_exit(	'parsing arguments', 			...
				'color argument must be a *struct*',	...
				'1',					...
				40);
	end
	str_colorFileDir	= s_otlColor.str_colorFileDir;
	str_brainMRItr		= s_otlColor.str_brainMRItr;
	str_wmMRItr		= s_otlColor.str_wmMRItr;
	str_filledMRItr		= s_otlColor.str_filledMRItr;
end

workingDir	= cd;

str_otl2cor	= sprintf('otl2cor_scale.bash -s %s -o %s -p %s ', ...
				subjectDir, otlBaseDir, otlFilePrefix);
if ~b_scale
	str_otl2cor = strcat(str_otl2cor, ' -n ');
end

if length(str_colorFileDir)
	str_otl2cor = strcat(str_otl2cor, sprintf(' -c %s', str_colorFileDir));
end
if length(str_brainMRItr)
	str_otl2cor = strcat(str_otl2cor, sprintf(' -b %s', str_brainMRItr));
end
if length(str_wmMRItr)
	str_otl2cor = strcat(str_otl2cor, sprintf(' -w %s', str_wmMRItr));
end
if length(str_filledMRItr)
	str_otl2cor = strcat(str_otl2cor, sprintf(' -f %s', str_filledMRItr));
end

fprintf(1, 'Starting intial shell-based scaling and converting...\n');
ret = 0;
str_otl2cor
[ret str_console] = unix(str_otl2cor, '-echo');
if ret 
	error_exit( 	'performing shell-based scaling and converting', ...
			'an error was returned from the system', ...
			'2', 60);
end

fprintf(1, 'Starting cropping and misc tail conversions...\n');
ret = fsvolume_crop(subjectDir);
if ret 
	error_exit( 	'performing cropping and misc conversions', ...
			'an error was returned from "fsvolume_crop.m"', ...
			'3', 60);
end

if b_scale
	cd(workingDir);
	cd(subjectDir);
	subjectDir=cd;
	cd(workingDir);
	cd(otlBaseDir);
	otlBaseDir=cd;
	fprintf(1, 'Copying original image dimensions to COR-.info files...\n');
	str_dimCopy = sprintf('find . -name COR-.info -exec otl2cor_dimCopy.bash -o %s -c {} \\;', ...
			otlBaseDir);
	cdir			= sprintf('%s/mri', subjectDir);
	cd(cdir);
	[ret str_console]	= unix(str_dimCopy, '-echo');
	if ret
		error_exit( 'copying original dimensions to COR-.info files', ...
				'an error was returned from otl2cor_dimCopy.bash', ...
				'4', 60);
	end
	cd(workingDir);
end

fprintf('Normal termination.\n\n');

end
