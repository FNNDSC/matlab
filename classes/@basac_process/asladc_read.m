function c = asladc_read(c, varargin)
%
% NAME
%
%  function c = asladc_read(c   ...
%       [, astr_ASLfile, astr_ADCfile, astr_ASLorig, astr_ADCorig])
%
% ARGUMENTS
% INPUT
%	c		class		basac_process class
% 
% OPTIONAL      
%       astr_ASLfile    string          name of the normalized ASL file
%       astr_ADCfile    string          name of the normalized ADC file      
%       astr_ASLorig    string          name of the orig (masked) ASL
%       astr_ADCorig    string          name of the orig (masked) ADC
%
% DESCRIPTION
%
%	This function reads/creates the ASL and ADC files,
%       and populates the relevant volume structures internally.
%       If <astr_ADCfile> and/or <astr_ASLfile> are not passed
%       in the function argument list, the function assumes the
%       names have been specified through a call to set(...)
%       and retrieves the file names from class member values.      
%
% PRECONDITIONS
%
%       o b0mask_read has been called.
%	o input files are some format understood by MRIread.
%       o input files are intensity NORMALIZED!
%       o the 'orig' file volumes are strictly positive.      
% 
% POSTCONDITIONS
% 
%       o c.mSMRI_* structures are populated for ASL and ADC
%       o Related volume structures are populated
%       o ASL volume is "inverted"
%
% NOTE:
%
% HISTORY
% 16 December 2008
% o Initial design and coding.
%
% 06 January 2009
% o Expanded with variable argument list.
% 
% 15 September 2009
% o Added support for orig ASL/ADC.
% 

c.mstack_proc 	= push(c.mstack_proc, 'asladc_read');

LC		= c.m_marginLeft;
RC		= c.m_marginRight;


if length(varargin) >=1; 
  str_aslInput          = varargin{1};
  str_dir               = dirname(str_aslInput);
  if str_dir ~= '.'; c.mstr_asladcInputDir = str_dir; end;
  c.mstr_aslInputFile   = basename(str_aslInput);
end

if length(varargin) >=2; 
  str_adcInput          = varargin{2};
  c.mstr_adcInputFile   = basename(str_adcInput);
end

if length(varargin) >=3;
  str_aslOrig           = varargin{3};
  c.mstr_aslOrigFile    = basename(str_aslOrig);
end

if length(varargin) >=4;
  str_adcOrig           = varargin{4};
  c.mstr_adcOrigFile    = basename(str_adcOrig);
end

str_asladcDir   = c.mstr_asladcInputDir;
str_ADCfile     = c.mstr_adcInputFile;
str_ASLfile     = c.mstr_aslInputFile;
str_ADCorig     = c.mstr_adcOrigFile;
str_ASLorig     = c.mstr_aslOrigFile;

astr_ADCfile    = sprintf('%s/%s', c.mstr_asladcInputDir, c.mstr_adcInputFile);
astr_ASLfile    = sprintf('%s/%s', c.mstr_asladcInputDir, c.mstr_aslInputFile);
astr_ADCorig    = sprintf('%s/%s', c.mstr_asladcInputDir, c.mstr_adcOrigFile);
astr_ASLorig    = sprintf('%s/%s', c.mstr_asladcInputDir, c.mstr_aslOrigFile);

a_existADC      = exist(astr_ADCfile, 'file');
a_existASL      = exist(astr_ASLfile, 'file');
a_existADCorig  = exist(astr_ADCorig, 'file');
a_existASLorig  = exist(astr_ASLorig, 'file');

if ~a_existADC
	error_exit(c, 'basal_process:asladc_read', ...
	    sprintf('The specified volume\n%s\nwas not found.', astr_ADCfile));
end    
if ~a_existASL
        error_exit(c, 'basal_process:asladc_read', ...
            sprintf('The specified volume\n%s\nwas not found.', astr_ASLfile));
end    
if ~a_existASLorig
        error_exit(c, 'basal_process:asladc_read', ...
            sprintf('The specified volume\n%s\nwas not found.', astr_ASLorig));
end
if ~a_existADCorig
        error_exit(c, 'basal_process:asladc_read', ...
            sprintf('The specified volume\n%s\nwas not found.', astr_ADCorig));
end

sys_print('| Reading specified ADC / ASL MRI structures - START\n');
cprints('Reading ADC structures', '');
c.mSMRI_ADC             = MRIread(astr_ADCfile);
c.mSMRI_ADCorig         = MRIread(astr_ADCorig);
cprintsn('', '[ ok ]');

cprints('Reading ASL structures', '');
c.mSMRI_ASL             = MRIread(astr_ASLfile);
c.mSMRI_ASLorig         = MRIread(astr_ASLorig);
cprintsn('', '[ ok ]');

cprints('Reading voxel size', '');
c.mv_voxelSize    = [ c.mSMRI_ADC.xsize/10 c.mSMRI_ADC.ysize/10 c.mSMRI_ADC.zsize/10 ];
cprintsn('', '[ ok ]');

c.mVn_ADC       = c.mSMRI_ADC.vol;
c.mVn_ASL       = c.mSMRI_ASL.vol;
c.mV_ADCB0      = c.mSMRI_ADCorig.vol;
c.mV_ASLB0      = c.mSMRI_ASLorig.vol;

if strcmp(c.mstr_runType, 'self-asl'); c.mVn_ADC = c.mVn_ASL; end;
if strcmp(c.mstr_runType, 'self-adc'); c.mVn_ASL = c.mVn_ADC; end;

if(c.mb_invASL)
  cprints('Inverting ASL volume', '');
  c.mVinv_ASL   = vol_invert(c.mVn_ASL, c.mV_B0);
  cprintsn('', '[ ok ]');
else
  cprints('Preserving ASL intensities', '');
  c.mVinv_ASL   = c.mVn_ASL;
  cprintsn('', '[ ok ]');
end

sys_print('| Reading specified ADC / ASL MRI structures - END\n');

[c.mstack_proc, element]= pop(c.mstack_proc);

end


















