function c = ROI_findStatistically(c, varargin)
%
% NAME
%
%  function c = ROI_findStatistically(c)
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

c.mstack_proc 	= push(c.mstack_proc, 'ROI_findStatistically');

sys_print('| Determining statistical ROIs - START\n');

if c.m_ROIfilterCount == -1
    ROIfilterLoop	= 100;
    b_breakOnTolerance	= 1;
else
    ROIfilterLoop	= c.m_ROIfilterCount;
    b_breakOnTolerance	= 1;
end

cprintsn('Analyzing ADC...', '[ start ]');
Vn_ADC			= c.mVn_ADC;
f_meanMaskOld		= 0.0;
c.mVn_ADCcopy		= c.mVn_ADC;
if c.mb_ADCsuppressCSF
   V_ADCroiCSF		= Vn_ADC * 0;
  for i=1:ROIfilterLoop
    cprintsn('Suppress CSF Loop', sprintf('[ %d/%d ]', i, c.m_ROIfilterCount));
    [c.mV_ADCroiCSF, f_meanMask, f_stdMask]	= vol_statROI(		...
						    c.mVn_ADC, 		...
						    c.mf_stdOffsetADCCSF,...
						    c.mV_B0,		...
						    Vn_ADC);
%      V_ADCroiCSF		= V_ADCroiCSF + c.mV_ADCroiCSF;
    V_ADCroiCSF(find(c.mV_ADCroiCSF>0))		= c.mV_ADCroiCSF(find(c.mV_ADCroiCSF>0));
    Vn_ADC(find(c.mV_ADCroiCSF>0))		= f_meanMask;
    f_meanDiff = abs(f_meanMask - f_meanMaskOld);
    cprintsn('Mean mask difference ADC', sprintf('[ %f ]', f_meanDiff));
    if f_meanDiff <= c.mf_meanMaskTolerance && b_breakOnTolerance; break; end
    f_meanMaskOld	= f_meanMask;
  end
  c.mVn_ADC		= Vn_ADC;
  c.mV_ADCroiCSF	= V_ADCroiCSF;
end

Vn_ADC			= c.mVn_ADC;
f_meanMaskOld		= 0.0;
for i=1:ROIfilterLoop
    cprintsn('Loop', sprintf('[ %d/%d ]', i, c.m_ROIfilterCount));
    [c.mV_ADCroi, f_meanMask, f_stdMask]	= vol_statROI(		...
						    c.mVn_ADC, 		...
						    c.mf_stdOffsetADC,	...
						    c.mV_B0,		...
						    Vn_ADC);
%    vol_imshow(c.mV_ADCroi);
    Vn_ADC(find(c.mV_ADCroi>0))			= f_meanMask;
    f_meanDiff = abs(f_meanMask - f_meanMaskOld);
    cprintsn('Mean mask difference ADC', sprintf('[ %f ]', f_meanDiff));
    if f_meanDiff <= c.mf_meanMaskTolerance && b_breakOnTolerance; break; end
    f_meanMaskOld	= f_meanMask;
end
cprintsn('Analyzing ADC...', '[ done ]'); fprintf('\n');

cprintsn('Analyzing ASL...', '[ start ]');
Vinv_ASL		= c.mVinv_ASL;
f_meanMaskOld		= 0.0;
for i=1:ROIfilterLoop
    cprintsn('Loop', sprintf('[ %d/%d ]', i, c.m_ROIfilterCount));
    [c.mV_ASLroi, f_meanMask, f_stdMask]	= vol_statROI(		...
						    c.mVinv_ASL,	...
						    c.mf_stdOffsetASL, 	...
						    c.mV_B0,		...
						    Vinv_ASL);
%      vol_imshow(c.mV_ASLroi, 29);
    Vinv_ASL(find(c.mV_ASLroi>0))		= f_meanMask;
    f_meanDiff = abs(f_meanMask - f_meanMaskOld);
    cprintsn('Mean mask difference ASL', sprintf('[ %f ]', f_meanDiff));
    if f_meanDiff <= c.mf_meanMaskTolerance && b_breakOnTolerance; break; end
    f_meanMaskOld	= f_meanMask;
end
cprintsn('Analyzing ASL...', '[ done ]');

sys_print('| Determining statistical ROIs - END\n');

[c.mstack_proc, element] = pop(c.mstack_proc);

