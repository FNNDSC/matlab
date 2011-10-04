function c = filtROI(c, varargin)
%
% NAME
%
%  function c = filtROI(c)
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
%
% NOTE:
%
% HISTORY
% 16 December 2008
% o Initial design and coding.
%

c.mstack_proc 	= push(c.mstack_proc, 'filtROI');

c.mV_ADCfilt    = vol_medfilt2(c.mV_ADCroi, c.mM_kernelADC);
c.mV_ASLfilt    = vol_medfilt2(c.mV_ASLroi, c.mM_kernelASL);
c.mv_ADCfilt    = vol_vectorize(c.mV_ADCfilt, c.mV_B0);
c.mv_ASLfilt    = vol_vectorize(c.mV_ASLfilt, c.mV_B0);

% Binarize the filt volumes?

[c.mstack_proc, element] = pop(c.mstack_proc);

