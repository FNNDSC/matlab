function c = ROI_medianFilter(c, varargin)
%
% NAME
%
%  function c = ROI_medianFilter(c)
%
% ARGUMENTS
% INPUT
%	c		class		basac_process class
%
% OPTIONAL
%
% OUTPUT
%	c		class		basac_process class
%	
%
% DESCRIPTION
%
%       Performs a median filtering on each slice of the ROI volumes in
%       <c>.
%       
% PRECONDITIONS
%
%	o the basac_process class instance must be fully instantiated.
%
% POSTCONDITIONS
%
%	o filtered volumes are created and stored.
%       o (masked) vectors of filtered regions are created and stored.      
%
% NOTE:
%
% HISTORY
% 16 December 2008
% o Initial design and coding.
%

c.mstack_proc 	= push(c.mstack_proc, 'ROI_medianFilter');

sys_print('| Median volume filtering - START\n');

if c.mb_ADCsuppressCSF
    cprints('Filtering ADC CSF...', '');
    c.mV_ADCfiltCSF = vol_medfilt2(c.mV_ADCroiCSF, c.mM_kernelADC);
    cprintsn('', '[ ok ]');
end

cprints('Filtering ADC...', '');
c.mV_ADCfilt    = vol_medfilt2(c.mV_ADCroi, c.mM_kernelADC); 
cprintsn('', '[ ok ]');

cprints('Filtering ASL...', '');
c.mV_ASLfilt    = vol_medfilt2(c.mV_ASLroi, c.mM_kernelASL);
cprintsn('', '[ ok ]');

cprints('Volume vectorizing ADC...', '');
c.mv_ADCfilt    = vol_vectorize(c.mV_ADCfilt, c.mV_B0);
cprintsn('', '[ ok ]');

cprints('Volume vectorizing ASL...', '');
c.mv_ASLfilt    = vol_vectorize(c.mV_ASLfilt, c.mV_B0);
cprintsn('', '[ ok ]');

% Binarize the filt volumes?
sys_print('| Median volume filtering - END\n');

[c.mstack_proc, element] = pop(c.mstack_proc);

