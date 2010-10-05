function ret = motl2cor(subjectDir, otlBaseDir, otlFilePrefix, 	...
			b_scale, b_crop, b_conformToMinimum,	...
			varargin)
% NAME
%
%	function ret = motl2cor(	subjectDir, 		...
%					otlBaseDir,		...
%					otlFilePrefix,		...
%					b_scale,		...
%					b_crop [,		...
%					b_conformToMinimum,	...
%					s_otlColor])
%
% ARGUMENTS
% inputs
%	subjectDir	in (string)	the "root" directory to house
%					FreeSurfer data converted from
%					a set of CardViews outlines.
%	otlBaseDir	in (string)	the "root" directory containing
%					<subjectDir>'s CardViews Outline
%					files.
%	otlFilePrefix	in (string)	A unique prefix identifier for a
%					group of CardViews segmentations.
%	b_scale		in (int)	A Boolean flag that toggles the
%					CardViews info.gdf scaling ON/OFF.
%	b_crop		in (int)	A Boolean flag that toggles the
%					volume cropping ON/OFF.
%
% optional
%	b_conformToMinimum in (bool)	An optional flag that if true 
%					passes the '-cm' (conform to
%					miniumum) flag to the underlying
%					conversion. If specified, converted
%					volumes will be 256x256x256 1mm^3;
%					if not, FreeSurfer volumes will
%					maintain CardViews dimensions.
%	s_otlColor	in (struct)	An optional structure conforming
%					to 'otlColor_struct(...)' that
%					contains additional parameters
%					used to specify color files and
%					color translation tables.
%
% outputs
%	ret		out (int)	Zero if no error has occurred
%					One if some error has occurred.
%
% DESCRIPTION
%
%	'motl2cor' (Meta- OuTLine 2 COR) is a MatLAB script function that
%	controls several bash-coded shell scripts that taken together
%	convert, scale, and crop a set of CardViews format segmentations
%	into FreeSurfer compatible (and tkmedit friendly) COR format
%	files.
%
%	Most of the "heavy lifting" is done by the 'mri_convert' process -
%	this family of MatLAB functions and shell scripts implements connective
%	plumbing that controls and directs the flow of information between
%	CardViews format, through 'mri_convert', and to FreeSurfer.
%
%	Since the cropping of volume files is best implemented in MatLAB, this
%	main (or Meta) controller is also implemented in MatLAB.
%
% PRECONDITIONS
%
%	o The parent MatLAB process must be run from the nmr-std-env 
%	  environment ('nse' for bash) -- this is for running 
%	  'mri_convert'.
%
%	o Assumes a UNIX/Linux runtime.
%
%	o Use otlColor_struct(...) to form the color-related tables.
%
%	o Make sure that the following shell scripts are on the system path:
%
%		otl2cor_scale.bash
%		otlinfo_scale.bash
%		otl2cor.bash
%
% POSTCONDITIONS
%
%	o For the given <subjectDir>, the corresponding set of CardViews
%	  outlines is converted into an isotropic 256^3 volume described
%	  in COR files, and housed in <subjectDir>/mri.
%
%	o Transitory intermediate files and conversion outputs are housed
%	  in MGH and COR format in <subjectDir>/mri_trans.
%
%	o If no errors have occured, the script returns zero (0), else an
%	  error text string.
%
% SEE ALSO
%
%	o 'fsvolume_crop.m'	- Converts and crops first-pass COR volumes.
%	o 'otlColor_struct.m'	- Structure housing color files and tables.
%
% HISTORY
%
% 21 December 2004
% o Initial design and coding.
%
% 23 January 2006
% o After a long hiatus, added control for specifying color tables.
%

global str_functionName;
str_functionName	= 'motl2cor';
str_colorFileDir	= '';
str_brainMRItr		= '';
str_wmMRItr		= '';
str_filledMRItr		= '';

% Check for color struct
if length(varargin)
	s_otlColor		= varargin{1};
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

if b_conformToMinimum
	str_otl2cor = strcat(str_otl2cor, ' -m ');
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
str_otl2cor
ret = 0;
[ret str_console] = unix(str_otl2cor, '-echo');
if ret 
	error_exit( 	'performing shell-based scaling and converting', ...
			'an error was returned from the system', ...
			'2', 60);
end

if b_crop
    fprintf(1, 'Starting cropping and misc tail conversions...\n');
    ret = fsvolume_crop(subjectDir);
    if ret 
	error_exit( 	'performing cropping and misc conversions', ...
			'an error was returned from "fsvolume_crop.m"', ...
			'3', 60);
    end
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
