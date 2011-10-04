function c = correlate(c, varargin)
%
% NAME
%
%  function c = correlate(c)
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
%       Creates necessary data structures and runs a volume slice-by-slice
%       based correlation on the ASL and ADC filtered volumes.
%       
% PRECONDITIONS
%
%	o the basac_process class instance must be fully instantiated.
%       o the ASL and ADC volumes must have been preprocessed to the
%         filtered stage.      
%
% POSTCONDITIONS
%
%	o The results of a slice-by-slice normxcorr2 are stored in
%         c.mV_correlate      
%
% NOTE:
%
% HISTORY
% 18 December 2008
% o Initial design and coding.
%

c.mstack_proc 	= push(c.mstack_proc, 'correlate');
sys_print('| Determining volume correlation - START\n');

m_sizeADC       = size(c.mV_ADCfilt);
c.mV_ADClarge   = zeros(m_sizeADC(1)*2, m_sizeADC(2)*2, m_sizeADC(3));
center          = floor((m_sizeADC-1)/2);
for i=1:m_sizeADC(3)
  c.mV_ADClarge(:,:,i) = putBinA( c.mV_ADClarge(:,:,i), c.mV_ADCfilt(:,:,i),...
                              center(1), center(2));      
end

cprintsn('Registration penalize',				...
	sprintf('[ %d ]', c.mb_registrationPenalize));
if c.mb_registrationPenalize
    cprintsn('Penalize function', sprintf('[ %s ]', 		...
	    c.mstr_registrationPenalizeFunc));
end
c.mV_correlation                = vol_normxcorr2(c.mV_ASLfilt, c.mV_ADClarge);
c.mv_maxCorrelationPerSlice     = zeros(1, m_sizeADC(3));
c.mv_maxCorrelationPerSliceW	= c.mv_maxCorrelationPerSlice;
c.mv_registrationOffset		= c.mv_maxCorrelationPerSlice;
m_sizeCV                        = size(c.mV_correlation);
j                               = 1;
f_diagSliceDistance		= vector_distance(		...
					[0            0], 	...
					[m_sizeADC(1) m_sizeADC(2)]);
for i=1:m_sizeCV(3)
    c.mv_maxCorrelationPerSlice(i) = max(max(c.mV_correlation(:,:,i)));
    if c.mv_maxCorrelationPerSlice(i)
      if c.mb_registrationPenalize
	[xcADC ycADC] 			= ait_centroid(c.mV_ADCfilt(:,:,i));
	[xcASL ycASL]			= ait_centroid(c.mV_ASLfilt(:,:,i));
	f_dist				= vector_distance(	...
						[xcADC ycADC], 	...
						[xcASL ycASL]);
	f_x				= f_dist / f_diagSliceDistance;
	c.mv_registrationOffset(i)	= f_x;
	f_w				= 1 - f_x;
	if strcmp(c.mstr_registrationPenalizeFunc, 'sigmoid')
	    f_w				= f_sigmoid01(f_x, 40, -6);
	end
      else
	f_w				= 1.0;
      end
      c.mv_maxCorrelationPerSliceW(i) 	= c.mv_maxCorrelationPerSlice(i) * f_w;
      j = j + 1;
    end
end

X       = [ c.mv_ADCfilt c.mv_ASLfilt ];
R       = corr(X);

c.mv_maxCorrelationPerSliceR    = c.mv_maxCorrelationPerSliceW;
c.mv_maxCorrelationPerSliceW    = pulse_filter(c.mv_maxCorrelationPerSliceW);
c.mv_maxCorrelation             = compress(c.mv_maxCorrelationPerSliceW);
c.mf_integralCorrelation        = trapz(c.mv_maxCorrelationPerSliceW);

sys_print('| Determining volume correlation - END\n');

[c.mstack_proc, element] = pop(c.mstack_proc);

