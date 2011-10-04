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
c		= inputImages_read(c);
c		= outputDicom_write(c);

[c.mstack_proc, element] = pop(c.mstack_proc);

