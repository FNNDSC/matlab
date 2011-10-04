function c = correlation_report(c, av_correlation)
%
% NAME
%
%  function c = correlation_report(c, av_correlation)
%
% ARGUMENTS
% INPUT
%	c		class		basac_process class
%       av_correlation  vector          vector of per-slice correlations
%
% OPTIONAL
%
% OUTPUT
%	c		class		basac_process class
%
% DESCRIPTION
%
%       Generates a report on the correlation.
%       
% PRECONDITIONS
%
%       o Valid av_correlation vector.
%	o Typically called from 'correlate()'.
%
% POSTCONDITIONS
%
%       o Report contains:
%               - mean non-zero max correlation
%               - correlation integral
%               - ADC correlation vol
%               - ASL correlation vol
%
% NOTE:
%
% HISTORY
% 20 August 2009
% o Initial design and coding.
%

c.mstack_proc 	= push(c.mstack_proc, 'correlation_report');

if numel(c.mv_maxCorrelation)
    c.mf_meanCorrelation        = mean(c.mv_maxCorrelation);
else
    c.mf_meanCorrelation        = 0.0;
end

% Generate volumes with ROIs and filts superimposed on original
% copies. This output will only be meaningful if data has been
% binarized (the default)
if c.mb_ADCsuppressCSF
    c.mV_ADCroiADCCSF = c.mVn_ADCcopy + c.mV_ADCfiltCSF;
end
c.mV_ADCroiADC  = c.mVn_ADCcopy + c.mV_ADCroi;
c.mV_ADCfiltADC = c.mVn_ADCcopy + c.mV_ADCfilt;
c.mV_ASLroiASL  = c.mVn_ASL     + c.mV_ASLroi;
c.mV_ASLfiltASL = c.mVn_ASL     + c.mV_ASLfilt;

f_scale         = prod(c.mv_voxelSize);
fprintf('\n');
cprintsn('ADC ROI f(Vn) mean',                                  ...
        sprintf('[ %.5f ]', c.stats_ADCnormF.mf_mean));
cprintsn('ADC ROI f(Vn) voxels',                                ...
        sprintf('[ %d ]', c.stats_ADCnormF.m_size));
cprintsn('ADC ROI f(Vn) volume',                                ...
        sprintf('[ %.2f ml]', c.stats_ADCnormF.m_size * f_scale));
cprintsn('ADC ROI nf(Vn) mean',                                 ...
        sprintf('[ %.5f ]', c.stats_ADCnormNF.mf_mean));
cprintsn('ADC ROI nf(Vn) voxels',                               ...
        sprintf('[ %d ]', c.stats_ADCnormNF.m_size));
cprintsn('ADC ROI nf(Vn) volume',                               ...
        sprintf('[ %.2f ml]', c.stats_ADCnormNF.m_size * f_scale));
cprintsn('ASL ROI f(Vn) mean',                                  ...
        sprintf('[ %.5f ]', c.stats_ASLnormF.mf_mean));
cprintsn('ASL ROI f(Vn) voxels',                                ...
        sprintf('[ %d ]', c.stats_ASLnormF.m_size));
cprintsn('ASL ROI f(Vn) volume',                                ...
        sprintf('[ %.2f ml]', c.stats_ASLnormF.m_size * f_scale));
cprintsn('ASL ROI nf(Vn) mean',                                 ...
        sprintf('[ %.5f ]', c.stats_ASLnormNF.mf_mean));
cprintsn('ASL ROI nf(Vn) voxels',                               ...
        sprintf('[ %d ]', c.stats_ASLnormNF.m_size));
cprintsn('ASL ROI nf(Vn) volume',                               ...
        sprintf('[ %.2f ml]', c.stats_ASLnormNF.m_size * f_scale));

fprintf('\n');
cprintsn('ADC ROI f(V0) mean',                                  ...
        sprintf('[ %.2f ]', c.stats_ADCorigF.mf_mean));
cprintsn('ADC ROI f(V0) std',                                   ...
        sprintf('[ %.2f ]', c.stats_ADCorigF.mf_std));
cprintsn('ADC ROI nf(V0) mean',                                 ...
        sprintf('[ %.2f ]', c.stats_ADCorigNF.mf_mean));
cprintsn('ADC ROI nf(V0) std',                                  ...
        sprintf('[ %.2f ]', c.stats_ADCorigNF.mf_std));
fprintf('\n');

cprintsn('ASL ROI f(V0) mean',                                  ...
        sprintf('[ %.2f ]', c.stats_ASLorigF.mf_mean));
cprintsn('ASL ROI f(V0) std',                                   ...
        sprintf('[ %.2f ]', c.stats_ASLorigF.mf_std));
cprintsn('ASL ROI nf(V0) mean',                                 ...
        sprintf('[ %.2f ]', c.stats_ASLorigNF.mf_mean));
cprintsn('ASL ROI nf(V0) std',                                  ...
        sprintf('[ %.2f ]', c.stats_ASLorigNF.mf_std));
fprintf('\n');

cprintsn('Mean non-zero max correlation',                       ...
        sprintf('[ %.2f ]', c.mf_meanCorrelation));
cprintsn('Correlation vector integral',                         ...
        sprintf('[ %.2f ]', c.mf_integralCorrelation));
cprintsn('ADC ROI voxels',                                      ...
        sprintf('[ %d ]', c.m_ADCroiVoxels));
cprintsn('ADC ROI volume',                                      ...
        sprintf('[ %.2f ml]', c.mf_ADCroiVol));
cprintsn('ASL ROI voxels',                                      ...
        sprintf('[ %d ]', c.m_ASLroiVoxels));
cprintsn('ASL ROI volume',                                      ...
        sprintf('[ %.2f ml]', c.mf_ASLroiVol));
cprintsn('ROI contiguous slices',                               ...
        sprintf('[ %d ]', numel(c.mv_maxCorrelation)));

[c.mstack_proc, element] = pop(c.mstack_proc);

end