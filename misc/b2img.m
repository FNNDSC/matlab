function c = b2img(topLevelDir, flagTarget, addTarget, varargin)
%
% NAME
%
%	function c = b2img(topLevelDir, flagTarget, addTarget, ...
%				['mgh'|'img'], b_keepTmp)
%
% ARGUMENTS
%
%	topLevelDir	in (string)	the "root" node from which
%					to recursively find and 
%					convert any <addTarget> files
%
%	flagTarget	in (string)	a filename to flag in the
%					initial search. This determines
%					which directories to analyze;
%					typically this is 'ADC.bshort'
%					or 'ADC.bfloat'
%
%	addTarget	in (string)	a simple regex that is passed to
%					the system 'ls'. This identifies
%					the files in the <flagTarget> 
%					directory that should to be 
%					converted
%
%	'mgh' | 'img'	varargin	an optional string to force conversion
%					to the passed type. This string
%					should be 'mri_convert' friendly.
%
%	b_keepTmp	in (bool)	a flag that controls whether or not to
%					erase the intermediate tmp b-format
%					flat files. This is usually 0 (i.e
%					false), but can be set to 1 if a 
%					monolithic to flat-file b-format
%					conversion is desired.
%
%
%	c		out (int)	number of files converted.
%					Zero if some error has occurred.
%
% DESCRIPTION
%
%	'b2img' searches for all directories from <topLevelDir> that 
%	contain a file called <flagTarget>. In each of these directories,
%	all <addTarget> files are converted to Analyze img format.
%
%	It operates in a bi-phase process. First, all <addTarget> files
%	are identified, and converted to a bfloat format that 
%	'mri_convert' understands. Basically, the original data sets
%	are volume-based, while 'mri_convert' expects slice-based
%	data.
%
%	Subsequently, this function calls 'mri_convert' on the newly
%	created slice-based images, creating a corresponding Analyze
%	format img file for each original <btype> volume. 
%
%	Note that the convert format can be overloaded by passing 
%	a string designator in the function arguments (see synposis).
%
%	Finally, the intermediate slice-based bfloats are deleted.
%
% PRECONDITIONS
%
%	o The parent MatLAB process must be run from the nmr-std-env 
%	  environment ('nse' for bash) -- this is for running 
%	  'mri_convert'.
%
%	o The <addTarget> parameter should flag valid bshort or bfloat
%	  files!
%
%	o It is assumed (BUT NOT CHECKED) that all <btype> files 
%	  downstream from topLevelDir are in volume- (and not slice-)
%	  based format.
%
%	o Assumes a UNIX/Linux runtime.
%
% POSTCONDITIONS
%
%	o Converted img files are created in the same directory, with the
%	  same prefix, as the original <btype> files.
%

% HISTORY
%
% 28 October 2004
% o Initial design and coding.
%
% 01 November 2004
% o Changed the image directory that holds the converted data from 
%   'img' to 'b2img' -- this was to facilitate searches for img 
%   files created with this utility.
%
% 04 November 2004
% o Added code to check for the presence of a GE-style data file in
%  the target directory. If found, this file is parsed for its voxel
%  data, which is passed through to 'mri_convert'.
%
% 18 January 2005
% o Added ability to process *.ah image files. Are these some old GE
%   format?
%
% 31 January 2005
% o Added ability to convert to mgh format, with a 'mgh' string 
%   argument.
%
% 01 April 2005
% o Added 'b_keepTmp' to keep intermediate b-format temp files.
% 

c 		= 0;	% final return value
b_keepTmp	= 0;

str_convertTo	= 'img';
if length(varargin)
	str_convertTo	= varargin{1};
	if length(varargin) == 2
		b_keepTmp   = varargin{2};
	end
end
	
cd(topLevelDir);

str_target	= flagTarget;		% The target search file. All
					% directories containing this file
					% are flagged for further processing

str_findCMD		= sprintf('find . -name %s', str_target);
[ret str_targetFiles]	= system(str_findCMD);
if ~sum(size(str_targetFiles))
	fprintf(1, 'No %s files were found!\nSearch directory: %s\n', str_target, topLevelDir);
	fprintf(1, '\tReturning to MatLAB with return value 0.\n\n');
	return;
end

[str_btypeDir str_rem] = strtok(str_targetFiles, char(10));
str_pathStart=cd;
while length(str_rem)
	cd(str_pathStart);
	i 	= findstr(str_target, str_btypeDir);
	path	= str_btypeDir(1:i-1);
	cd(path);
	fprintf(1, '\nConverting in directory %s\n', path);
	system('rm -fr b2img 2>/dev/null');
	system('mkdir b2img 2>/dev/null');
	system('rm -fr tmp 2>/dev/null');
	system('mkdir tmp 2>/dev/null');
	str_lsCMD = sprintf('ls %s 2>/dev/null', addTarget);
	[ret str_btypeAllFiles]	= system(str_lsCMD);
	str_lsCMD = sprintf('ls *1.1');
	[retGEhdr str_GEhdr] = system(str_lsCMD);
	if ~retGEhdr
		fprintf(1, 'GE-type data file detected. Extracing voxel info...\n');
		str_Xfind = [ 'awdisphdr -i ' str_GEhdr(1:length(str_GEhdr)-1) ...
			' | grep pixel | grep X | awk ' char(39) '{print $7}' char(39) ];
		[ret str_X] = system(str_Xfind);
		str_X = str_X(1:length(str_X)-1);
		fprintf(1, 'X - voxel size:\t\t\t[ %s ]\n', str_X);
		str_Yfind = [ 'awdisphdr -i ' str_GEhdr(1:length(str_GEhdr)-1) ...
			' | grep pixel | grep Y | awk ' char(39) '{print $7}' char(39) ];
		[ret str_Y] = system(str_Yfind);
		str_Y = str_Y(1:length(str_Y)-1);
		fprintf(1, 'Y - voxel size:\t\t\t[ %s ]\n', str_Y);
		str_Zfind = [ 'awdisphdr -i ' str_GEhdr(1:length(str_GEhdr)-1) ...
			' | grep Thickness | awk ' char(39) '{print $5}' char(39) ];
		[ret str_Z] = system(str_Zfind);
		str_Z = str_Z(1:length(str_Z)-1);
		fprintf(1, 'Z - voxel size:\t\t\t[ %s ]\n', str_Z);
	end
	str_lsCMD = sprintf('ls *ah');
	[retAHhdr str_AHhdr] = system(str_lsCMD);
	if ~retAHhdr
		fprintf(1, 'AH-type data file detected...\n');
		str_lsCMD = sprintf('ls ADC_img.img');
		[retIMGhdr str_IMGhdr] = system(str_lsCMD);
		if ~retIMGhdr
			fprintf(1, 'Parsing ADC_img.img for voxel info...\n');
		else
			fprintf(1, 'Warning! No ADC_img.img file found...\n');
			fprintf(1, 'Voxel extraction information WILL be incorrect!\n');
		end
		str_Xfind = [ 'mri_info ADC_img.img 2>/dev/null | grep "voxel sizes" | awk ' ... 
				char(39) '{print $3}' char(39) ];
		[ret str_X] = system(str_Xfind);
		str_X = str_X(1:length(str_X)-2);
		fprintf(1, 'X - voxel size:\t\t\t[ %s ]\n', str_X);
		str_Yfind = [ 'mri_info ADC_img.img 2>/dev/null | grep "voxel sizes" | awk ' ... 
				char(39) '{print $4}' char(39) ];
		[ret str_Y] = system(str_Yfind);
		str_Y = str_Y(1:length(str_Y)-2);
		fprintf(1, 'Y - voxel size:\t\t\t[ %s ]\n', str_Y);
		str_Zfind = [ 'mri_info ADC_img.img 2>/dev/null | grep "voxel sizes" | awk ' ... 
				char(39) '{print $5}' char(39) ];
		[ret str_Z] = system(str_Zfind);
		str_Z = str_Z(1:length(str_Z)-2);
		fprintf(1, 'Z - voxel size:\t\t\t[ %s ]\n', str_Z);
	end
	[str_btypeFile str_remFiles]	= strtok(str_btypeAllFiles);
	while length(str_remFiles)
		fprintf(1, '\t%s...\t', str_btypeFile);
		fprintf(1, '[ reading ]\t');
		adc = fast_ldbfile(str_btypeFile);
		fprintf(1, '[ writing ]\t');
		[str_name str_extension] = strtok(str_btypeFile, '.');
		fast_svbslice(adc, strcat('tmp/', str_name, '_'));
		fprintf(1, '[ converting ]\t');
		cd('tmp');
		str_convCMD = 'mri_convert ';
		if ~retGEhdr || ~retAHhdr
			str_convCMD = [ str_convCMD ' -iis ' str_X ' -ijs ' str_Y ' -iks ' str_Z ' ' ...
			 	' -iid -1 0 0 -ijd 0 -1 0 -ikd 0 0 1 ' ];
		end
		str_convCMD = [ str_convCMD str_name '__000.bfloat ../b2img/' str_name '.' ...
				str_convertTo ' 2>/dev/null >/dev/null' ];
		system(str_convCMD);
		c=c+1;
		cd('../');
		fprintf(1, '[ ok ]\n');
		[str_btypeFile str_remFiles] = strtok(str_remFiles);
	end
	fprintf(1, 'Cleaning up in directory %s\n', path);
	if ~b_keepTmp
		system('rm -fr tmp 2>/dev/null');
	end
	[str_btypeDir str_rem] = strtok(str_rem, char(10));
end


