function c = statROI(c, varargin)
%
% NAME
%
%  function c = statROI(c)
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
%       Perform a statistical ROI on the internal volume data
%
% PRECONDITIONS
%
%	o the basac_process class instance must be fully instantiated.
%
% POSTCONDITIONS
%
%	o Internal ROI volumes are created.
%
% NOTE:
%
% HISTORY
% 16 December 2008
% o Initial design and coding.
%

c.mstack_proc 	= push(c.mstack_proc, 'statROI');

c.mV_ADCroi     = vol_statROI(c.mVn_ADC,   c.mf_stdOffsetADC, c.mV_B0);
c.mV_ASLroi     = vol_statROI(c.mVinv_ASL, c.mf_stdOffsetASL, c.mV_B0);

[c.mstack_proc, element] = pop(c.mstack_proc);

