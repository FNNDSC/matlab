function [c] = basac_initialize(c, astr_profileName)
%
% NAME
%
%	function [c] = basac_initialize(c, astr_profileName)
%
% ARGUMENTS
% INPUT
%	c		        class		basac class
%       astr_profileName        string          string constant defining
%                                               initialization to perform
%
% OPTIONAL
%
% DESCRIPTION
% 
%       'basac_initialize' sets internal class state and control variables
%       to certain pre-defined constants.
%
% PRECONDITIONS
% 
%       o astr_profileName is one of:
%               - 'default'
%               - 'self-adc'
%               - 'self-asl'
%
% POSTCONDITIONS
% 
%       o default: sets ASL/ADC stdOffsets and kernel to standard stream
%       o self-adc: the ADC volume is self-correlated
%       o self-asl: the ASL volume is self-correlated
%
% NOTE:
%
% HISTORY
% 05 January 2009
% o Initial design and coding.
%

c.mstack_proc 	= push(c.mstack_proc, 'basac_initialize');

cprints(sprintf('Initializing to %s', astr_profileName), '');
switch astr_profileName
  case 'self-adc'                                   % ADC unit test
    c.mf_stdOffsetADC               = -1.5;         % Offset for ADC std analysis
    c.mf_stdOffsetASL               = -1.5;         % Offset for ASL std analysis
    c.mM_kernelADC                  = [7 7];        % Kernel size for median ADC filtering
    c.mM_kernelASL                  = [7 7];        % Kernel size for median ASL filtering 
    c.mb_invASL                     = 0;
  case 'self-asl'                                   % ASL unit test
    c.mf_stdOffsetADC               = 2.5;          % Offset for ADC std analysis
    c.mf_stdOffsetASL               = 2.5;          % Offset for ASL std analysis
    c.mM_kernelADC                  = [11 11];      % Kernel size for median ADC filtering
    c.mM_kernelASL                  = [11 11];      % Kernel size for median ASL filtering 
    c.mb_invASL                     = 0;
  otherwise                                         % Main processing
    c.mf_stdOffsetADC               = -1.5;         % Offset for ADC std analysis
    c.mf_stdOffsetASL               = -2.5;         % Offset for ASL std analysis
    c.mM_kernelADC                  = [7 7];        % Kernel size for median ADC filtering
    c.mM_kernelASL                  = [11 11];      % Kernel size for median ASL filtering 
    c.mb_invASL                     = 1;
end
c.mstr_runType  = astr_profileName;
cprintsn('', '[ ok ]');

[c.mstack_proc, element]= pop(c.mstack_proc);
