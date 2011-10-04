function c = b0mask_read(c, varargin)
%
% NAME
%
%  function c = b0_read(c [, astr_b0maskFile])
%
% ARGUMENTS
% INPUT
%	c		class		basac_process class
% 
% OPTIONAL      
%       astr_b0maskFile string          name of the b0 mask file
%
% DESCRIPTION
%
%	This function reads/creates the b0 mask file and structures.
%       If <astr_b0maskFile> is not passed the function argument
%       list, the function assumes that the relevant internal
%       class variables have been set and retrieves the file
%       name from class member values.      
%
% POSTCONDITIONS
%
%	o input files are some format understood by MRIread.
%
% NOTE:
%
% HISTORY
% 16 December 2008
% o Initial design and coding.
%
% 06 January 2009
% o Expanded with variable argument list
% 

c.mstack_proc 	= push(c.mstack_proc, 'b0mask_read');

LC		= c.m_marginLeft;
RC		= c.m_marginRight;

if length(varargin) >=1; 
  str_b0Input           = varargin{1};
  str_dir               = dirname(str_b0Input);
  if str_dir ~= '.'; c.mstr_b0MaskInputDir = str_dir; end;
  c.mstr_b0MaskInputFile= basename(str_b0Input);
end

astr_b0maskFile = sprintf('%s/%s', c.mstr_b0MaskInputDir,c.mstr_b0MaskInputFile);
a_existb0       = exist(astr_b0maskFile, 'file');

if ~a_existb0
	error_exit(c, 'basal_process:b0mask_read', ...
	    sprintf('The specified volume:\n%s\nwas not found.', astr_b0maskFile));
end    

sys_print('| Reading specified B0 MRI mask structure - START\n');
cprints('Reading B0 structure', '');
c.mSMRI_B0              = MRIread(astr_b0maskFile);
cprintsn('', '[ ok ]');

c.mV_B0                 = c.mSMRI_B0.vol;

sys_print('| Reading specified B0 MRI mask structure - END\n');
[c.mstack_proc, element]= pop(c.mstack_proc);

end


















