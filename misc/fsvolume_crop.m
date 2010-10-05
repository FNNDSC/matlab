function ret = fsvolume_crop(subjectDir)
% NAME
%
%	function ret = fsvolume_crop(subjectDir)
%
% ARGUMENTS
%
%	subjectDir	in (string)	the "root" directory to process
%
%	ret		out (int)	Zero if no error has occurred
%					One if some error has occurred.
%
% DESCRIPTION
%
%	'fsvolume_crop' in its simplest sense crops a > (256^3) volume down
%	to 256^3. It does this blindly - by defining a 256^3 volume about a
%	center point, and saving this volume.
%
%	Behind the scenes, so to speak, 'fsvolume' assumes COR type original
%	data in a particular directory tree, and uses 'mri_convert' to convert
%	this data to MGH format. This MGH is cropped, saved and then
%	re-'mri_convert'ed back to COR format.
%
%
% PRECONDITIONS
%
%	o Assumes that a directory tree structure as per 'otl2cor_scale.bash'
%	  has been created, with a corresponding <subjectDir> argument.
%
%	o By direct implication of the above, this function should probably
%	  be called from another function and not really directly by an
%	  end user.
%
%	o The parent MatLAB process must be run from the nmr-std-env 
%	  environment ('nse' for bash) -- this is for running 
%	  'mri_convert'.
%
%	o Assumes a UNIX/Linux runtime.
%
% POSTCONDITIONS
%
%	o In the 'otl2cor_scale.bash' <subjectDir>/mri_trans/*-256 directories
%	  are COR files defining a 256^3 volume space.
%
%	o If no errors have occured, the script returns zero (0), else an
%	  error text string.
%
% SEE ALSO
%
%	o 'motl2cor.m'	- Meta otl2cor MatLAB based controller script.
%
%
% HISTORY
%
% 20 December 2004
% o Initial design and coding.
%
% 22 February 2005
% o save_mgh2 <--> save_mgh3, with type data as MRI_UCHAR
%

ca_baseDir	= {['filled'] ['wm'] ['orig'] ['brain'] ['T1']};

[r c]	 	= size(ca_baseDir);

startDir	= cd;
fprintf(1, 'Processing in subject directory %s:\n', subjectDir);
workingDir	= strcat(subjectDir, '/mri_trans');
cd(workingDir);
for i = 1:c,
	dirCOR		= ca_baseDir{i};
	dirMGH		= strcat(ca_baseDir{i}, '-mgh');
	dirCOR256	= strcat(ca_baseDir{i}, '-256');
	fprintf(1, '    %s: ', dirCOR);
	if length(dirCOR)<8
		fprintf(1, '\t');
	end
	fprintf(1, '[ COR->MGH ');
	str_convert 	= sprintf('mri_convert %s %s/volume.mgh', dirCOR, dirMGH);
	[ret str_console] = system(str_convert);
	if ret
		fprintf(1, ' *error* ]\n\n');
		fprintf(1, 'stdout output:\n%s\n', str_console);
		error('1', 'Some error has occurred with "mri_convert"'); 	
	end
	fprintf(1, '] [ cropping ');
	str_volMGH	= sprintf('%s/volume.mgh', dirMGH);
	[V_volMGH, M_vox2ras, M_mrparams]	= load_mgh2(str_volMGH);
	[vc vr vs]	= size(V_volMGH);
	del		= int16(round(vc-256)/2);
	if del 
		V_volMGH256	= V_volMGH(del+1:del+256, del+1:del+256, del+1:del+256);
		str_volMGH256	= sprintf('%s/volume-256.mgh', dirMGH);
		fprintf(1, '] [ saving MGH256');
		save_mgh3(V_volMGH256, str_volMGH256, M_vox2ras, M_mrparams, 3);
	else
		V_volMGH256	= V_volMGH;
		str_copy	= sprintf('cp %s/volume.mgh %s/volume-256.mgh', dirMGH, dirMGH);
		fprintf(1, '] [ copying MGH256');
		[ret str_console] = system(str_copy);
		if ret
			fprintf(1, ' *cp error* ]\n\n');
			error('3', 'An error occurred with the system copy process.');
		end
	end
	fprintf(1, ' ] [ MGH256->COR256 ');
	str_convert	= sprintf('mri_convert -rt nearest -ns 1 %s/volume-256.mgh %s', dirMGH, dirCOR256);
	[ret str_console] = system(str_convert);
	if ret
		fprintf(1, ' *error* ]\n\n');
		fprintf(1, 'stdout output:\n%s\n', str_console);
		error('2', 'Some error has occurred with "mri_convert"'); 	
	end
	fprintf(1, '] [ COR256->COR ');
	str_copy	= sprintf('cp %s/* ../mri/%s', dirCOR256, dirCOR);
	[ret str_console] = system(str_copy);
	if ret
		fprintf(1, ' *error* ]\n\n');
		fprintf(1, 'stdout output:\n%s\n', str_console);
		error('3', 'Some error has occurred with the system copy process'); 	
	end
	fprintf(1, ']\n' );
end

cd(startDir)

