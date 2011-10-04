function c = run(c, varargin)
%
% NAME
%
%  function c = run(c, [<astr_volname>])
%
% ARGUMENTS
% INPUT
%	c		class		img2dcm class
%
% OPTIONAL
%
% OUTPUT
%	c		class		img2dcm class
%	
%
% DESCRIPTION
%
%	This method is the main entry point to "running" an img2dcm
%	class instance. It controls the main processing loop, viz. 
%
%		- reading original image files
%		- saving as dicom to output directory
%
% PRECONDITIONS
%
%	o the img2dcm class instance must be fully instantiated.
%
% POSTCONDITIONS
%
%	o The output directory  is populated with the dicom versions
%	  of the input files.
%
% NOTE:
%
% HISTORY
% 10 April 2008
% o Initial design and coding.
%

c.mstack_proc 	= push(c.mstack_proc, 'run');

c		= dicomHeader_read(c);
c.s_dicomFiles	= dir(sprintf('%s/%s', c.mstr_dicomInputDir, c.mstr_dirArg));

% Check if output dir exists -- create if not or die
s_dir		= dir(c.mstr_dicomOutputDir);
if ~numel(s_dir)
    [status, result] = unix(sprintf('mkdir %s', c.mstr_dicomOutputDir));
    if status
	error_exit('1', sprintf('Could not create output directory: %s',...
			    c.mstr_dicomOutputDir));
    end
end

c 		= header_newUID(c);

total		= numel(c.s_dicomFiles);
for dcmIn	= 1:total
    str_in	= c.s_dicomFiles(dcmIn).name;
    str_out	= sprintf('%s-%s', c.mstr_anonPrefix, str_in);
    str_info	= sprintf('%20s --> %20s (%d/%d)        ',		...
			    str_in, str_out, dcmIn, total);
    vprintf(c, 1, str_info);
    dicomanon(	sprintf('%s/%s', c.mstr_dicomInputDir,   str_in),	... 
		sprintf('%s/%s', c.mstr_dicomOutputDir, str_out),	...
		'keep',	c.c_keep, 'update', c.s_updateDicomInfo);
    str_b   	= '';
    for b=1:length(str_info)
	str_b = sprintf('%s%s', str_b, '\b');
    end
    vprintf(c, 1, str_b);
end

[c.mstack_proc, element] = pop(c.mstack_proc);

