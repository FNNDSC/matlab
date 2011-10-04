function [c] = inputImages_read(c, varargin)
%
% NAME
%
%	function [c] = inputImages_read(c [, astr_imagePat])
%
% ARGUMENTS
% INPUT
%	c		class		img2dcm class
%
% OPTIONAL
%	astr_imagePat	string		image file pattern
%
% DESCRIPTION
%
%	This method scans all the image files in c.mstr_imgInputDir
%	and stores the images to c.mcell_img.
%
% PRECONDITIONS
%
%	o c.mstr_imgInputDir must contain appropriate image files.
%
% POSTCONDITIONS
%
%	o c.mcell_img is populated.
%
% NOTE:
%
% HISTORY
% 10 April 2008
% o Initial design and coding.
%

c.mstack_proc 	= push(c.mstack_proc, 'inputImages_read');

str_imagePat	= '-1 *.png | sort -n -k 3 -t \-';

if length(varargin)
	str_imagePat	= varargin{1};
end
%  sys_print(c, sprintf('| Reading input images using image pattern: %s...\n', str_imagePat));

cd(c.mstr_imgInputDir);
cell_ls		= dls(str_imagePat);
imageNum	= length(cell_ls);

sys_print(c, sprintf('| Allocating space for %d images...', imageNum));
c.mcell_img		= cell(1, imageNum);
c.mcell_dcm		= cell(1, imageNum);
c.mcell_imgFileName	= cell(1, imageNum);
vprintf(c, 1, ' done.\n'); 
sys_print(c, sprintf('| Reading input images... '));
for i=1:imageNum
	str_info = sprintf('%04d/%04d: %s    ', i, imageNum, cell_ls{i});
	vprintf(c, 1, str_info);
	c.mcell_img{i}	= imread(cell_ls{i});
	str_filenameCMD	= [sprintf('echo %s ', cell_ls{i}) '| sed ' char(39) 's/\(.*\)\.\(.*\)/\1/' char(39)];
	[status ret]	= unix(str_filenameCMD);
	txtlen		= length(ret);
	c.mcell_imgFileName{i}	= ret(1:txtlen-1);
	str_b	= '';
	for b=1:length(str_info)
	    str_b = sprintf('%s%s', str_b, '\b');
	end
	vprintf(c, 1, str_b);
end
vprintf(c, 1, '\n');
sys_print(c, sprintf('| %s images read from input image directory.\n'), length(cell_ls));
cd(c.mstr_workingDir);

[c.mstack_proc, element]= pop(c.mstack_proc);
