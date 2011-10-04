function c = binarize(c, varargin)
%
% NAME
%
%  function c = binarize(c)
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
%       Binarizes the ASL and ADC filtered volumes, i.e. non-zero
%       intensities are hard-limited to 1.0.
%       
% PRECONDITIONS
%
%	o ADCfilt and ASLfilt
%
% POSTCONDITIONS
%
%	o This is a destructive process! The original data structures
%	  are replaced by their binarized equivalents.
%
% NOTE:
%
% HISTORY
% 30 March 2009
% o Initial design and coding.
%

c.mstack_proc 	= push(c.mstack_proc, 'binarize');
sys_print('| Binarizing filter volumes - START\n');

c.mV_ADCfilt(find(c.mV_ADCfilt>0.0))		= 1.0;
c.mV_ASLfilt(find(c.mV_ASLfilt>0.0))		= 1.0;
c.mV_ADCroi(find(c.mV_ADCroi>0.0))              = 1.0;
c.mV_ASLroi(find(c.mV_ASLroi>0.0))              = 1.0;
c.mV_ADCfiltCSF(find(c.mV_ADCfiltCSF>0.0))	= 1.0;

sys_print('| Binarizing filter volumes - END\n');

[c.mstack_proc, element] = pop(c.mstack_proc);

