function c = bshort2img(topLevelDir)
%
% NAME
%
%	function bshort2img(topLevelDir)
%
% ARGUMENTS
%
%	topLevelDir	in (string)	the "root" node from which
%					to recursively find and 
%					convert any *.bshort files
%
%	c		out (int)	number of bshort files converted.
%					Zero if some error has occurred.
%
% DESCRIPTION
%
%	'bshort2img' searches for all files from <topLevelDir> with
%	a bshort extension and converts them to Analyze img format.
%
%	It operates in a bi-phase process. First, all bshort files
%	are identified, and converted to a bfloat format that 
%	'mri_convert' understands. Basically, the original bshorts
%	are volume-based, while 'mri_convert' expects slice-based
%	data.
%
%	Subsequently, this function calls 'mri_convert' on the newly
%	created slice-based images, creating a corresponding Analyze
%	format img file for each original bshort volume.
%
%	Finally, the intermediate slice-based bfloats are deleted.
%
% PRECONDITIONS
%
%	o The parent MatLAB process must be run from the nmr-std-env 
%	  environment ('nse' for bash) -- this is for running 
%	  'mri_convert'.
%
%	o It is assumed (BUT NOT CHECKED) that all bshort files 
%	  downstream from topLevelDir are in volume- (and not slice-)
%	  based format.
%
%	o Assumes a UNIX/Linux runtime.
%
% POSTCONDITIONS
%
%	o Converted img files are created in the same directory, with the
%	  same prefix, as the original bshort files.
%
% HISTORY
%

% 27 October 2004
% o Initial design and coding.
%

c = 0;

cd(topLevelDir);

str_target	= 'ADC.bshort';		% The bshort target search file. It 
					% is assumed that several other bshort
					% files exist in the same directory
					% as this target.

str_findCMD		= sprintf('find . -name %s', str_target);
[ret str_targetFiles]	= system(str_findCMD);
if ~sum(size(str_targetFiles))
	fprintf(1, 'No ADC.bshort files were found!\nSearch directory: %s\n', topLevelDir);
	fprintf(1, '\tReturning to MatLAB with return value 0.\n\n');
	return;
end

[str_bshortDir str_rem] = strtok(str_targetFiles, char(10));
str_pathStart=cd;
while length(str_rem)
	cd(str_pathStart);
	i 	= findstr(str_target, str_bshortDir);
	path	= str_bshortDir(1:i-1);
	cd(path);
	fprintf(1, '\nConverting in directory %s\n', path);
	system('mkdir img 2>/dev/null');
	system('mkdir tmp 2>/dev/null');
	[ret str_bshortAllFiles]	= system('ls *bshort');
	[str_bshortFile str_remFiles]	= strtok(str_bshortAllFiles);
	while length(str_remFiles)
		fprintf(1, '\t%s...\t', str_bshortFile);
		fprintf(1, '[ reading ]\t');
		adc = fast_ldbfile(str_bshortFile);
		fprintf(1, '[ writing ]\t');
		[str_name str_extension] = strtok(str_bshortFile, '.');
		fast_svbslice(adc, strcat('tmp/', str_name, '_'));
		fprintf(1, '[ converting ]\t');
		cd('tmp');
		str_convCMD=sprintf('mri_convert %s__000.bfloat ../img/%s.img 2>/dev/null >/dev/null', str_name, str_name);
		system(str_convCMD);
		c=c+1;
		cd('../');
		fprintf(1, '[ ok ]\n');
		[str_bshortFile str_remFiles] = strtok(str_remFiles);
	end
	fprintf(1, 'Cleaning up in directory %s\n', path);
	system('rm -fr tmp 2>/dev/null');
	[str_bshortDir str_rem] = strtok(str_rem, char(10));
end


