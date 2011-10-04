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

cprintsn('Mean non-zero max correlation',                       ...
        sprintf('[ %f ]', c.mf_meanCorrelation));
cprintsn('Correlation vector integral',                         ...
        sprintf('[ %f ]', c.mf_integralCorrelation));
cprintsn('ADC ROI voxels',                                      ...
        sprintf('[ %d ]', c.m_ADCroiVoxels));
cprintsn('ADC ROI volume',                                      ...
        sprintf('[ %f ]', c.mf_ADCroiVol));
cprintsn('ASL ROI voxels',                                      ...
        sprintf('[ %d ]', c.m_ASLroiVoxels));
cprintsn('ASL ROI volume',                                      ...
        sprintf('[ %f ]', c.mf_ASLroiVol));
cprintsn('ADC ROI f(Vn) mean',                                  ...
        sprintf('[ %f ]', c.stats_ADCnormF.mf_mean));
cprintsn('ADC ROI nf(Vn) mean',                                 ...
        sprintf('[ %f ]', c.stats_ADCnormNF.mf_mean));
cprintsn('ADC ROI f(V0) mean',                                  ...
        sprintf('[ %f ]', c.stats_ADCorigF.mf_mean));
cprintsn('ADC ROI nf(V0) mean',                                 ...
        sprintf('[ %f ]', c.stats_ADCorigNF.mf_mean));
cprintsn('ASL ROI f(Vn) mean',                                  ...
        sprintf('[ %f ]', c.stats_ASLnormF.mf_mean));
cprintsn('ASL ROI nf(Vn) mean',                                 ...
        sprintf('[ %f ]', c.stats_ASLnormNF.mf_mean));
cprintsn('ASL ROI f(V0) mean',                                  ...
        sprintf('[ %f ]', c.stats_ASLorigF.mf_mean));
cprintsn('ASL ROI nf(V0) mean',                                 ...
        sprintf('[ %f ]', c.stats_ASLorigNF.mf_mean));
cprintsn('ROI contiguous slices',                               ...
        sprintf('[ %d ]', numel(c.mv_maxCorrelation)));

[c.mstack_proc, element] = pop(c.mstack_proc);

end