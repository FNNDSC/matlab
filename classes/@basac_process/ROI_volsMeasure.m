function c = ROI_volsMeasure(c, varargin)
%
% NAME
%
%  function c = ROI_volsMeasure(c)
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
%       Determines the volumes of the correlated regions on the ASL and
%       ADC images.
%       
%       Also determines intensity stats on the ROI filtered and non ROI
%       voxels.
%       
% PRECONDITIONS
%
%	o Valid c.mv_voxelSize
%       o Valid c.mv_maxCorrelationPerSliceW
%       
% POSTCONDITIONS
%
%       o c.m_ADCroiVoxels
%       o c.m_ASLroiVoxels
%       o c.mf_ADCroiVol
%       o c.mf_ASLroiVol
%
% NOTE:
%
% HISTORY
% 20 August 2009
% o Initial design and coding.
%
% 15 September 2009
% o Added stats on final volumes.

c.mstack_proc 	= push(c.mstack_proc, 'ROI_volsMeasure');

sys_print('| ADC/ASL ROI volume and stats measures - START\n');

for slice = 1:numel(c.mv_maxCorrelationPerSliceW)
    if(c.mv_maxCorrelationPerSliceW(slice))
        M_ADC                   = c.mV_ADCfilt(:,:,slice);
        M_ASL                   = c.mV_ASLfilt(:,:,slice);
        c.m_ADCroiVoxels        = c.m_ADCroiVoxels + sum(M_ADC(:));
        c.m_ASLroiVoxels        = c.m_ASLroiVoxels + sum(M_ASL(:));
    else
        % Zero any slices that have been pulsefiltered
        c.mV_ADCfilt(:,:,slice) = c.mV_ADCfilt(:,:,slice) * 0;
        c.mV_ASLfilt(:,:,slice) = c.mV_ASLfilt(:,:,slice) * 0;
    end
end
cprintsn('Volumes calculated', '[ ok ]');

f_scale         = prod(c.mv_voxelSize);
c.mf_ADCroiVol  = c.m_ADCroiVoxels * f_scale;
c.mf_ASLroiVol  = c.m_ASLroiVoxels * f_scale;

c.mV_ASLB0      = c.mV_ASLB0 * c.mf_ASLorigScale;
c.mV_ADCB0      = c.mV_ADCB0 * c.mf_ADCorigScale;
c.stats_ASLnormF = vol_stats(c.mVn_ASL, vol_binarize(c.mV_ASLfilt));

if c.stats_ASLnormF.m_size ~= c.m_ASLroiVoxels+1
    error_exit(c, 'ASLroi', 'vol_stats did not return same size ASLroiVoxels');
end

if c.mb_filterOnRawROI
    V_filterMask      = vol_binarize(c.mV_ASLroi);
else
    V_filterMask      = vol_binarize(c.mV_ASLfilt);
end
V_nonFilterMask   = vol_binarize(c.mV_B0) - V_filterMask;
c.stats_ASLorigF  = vol_stats(c.mV_ASLB0, V_filterMask);
c.stats_ASLnormNF = vol_stats(c.mVn_ASL,  V_nonFilterMask);
c.stats_ASLorigNF = vol_stats(c.mV_ASLB0, V_nonFilterMask);
cprintsn('ASL stats calculated', ' [ ok ]');

c.stats_ADCnormF = vol_stats(c.mVn_ADC, vol_binarize(c.mV_ADCfilt));
if c.stats_ADCnormF.m_size ~= c.m_ADCroiVoxels+1
    error_exit(c, 'ADCroi', 'vol_stats did not return same size ADCroiVoxels');
end

if c.mb_filterOnRawROI
    V_filterMask      = vol_binarize(c.mV_ADCroi);
else
    V_filterMask      = vol_binarize(c.mV_ADCfilt);
end
V_filterMask      = vol_binarize(c.mV_ADCfilt);
V_nonFilterMask   = vol_binarize(c.mV_B0) - V_filterMask - vol_binarize(c.mV_ADCroiCSF);
c.stats_ADCorigF  = vol_stats(c.mV_ADCB0, V_filterMask);
c.stats_ADCnormNF = vol_stats(c.mVn_ADC,  V_nonFilterMask);
c.stats_ADCorigNF = vol_stats(c.mV_ADCB0, V_nonFilterMask);

cprintsn('ADC stats calculated', ' [ ok ]');

sys_print('| ADC/ASL ROI volume and stats measures - END\n');

[c.mstack_proc, element] = pop(c.mstack_proc);

