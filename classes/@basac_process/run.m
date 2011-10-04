function c = run(c, varargin)
%
% NAME
%
%  function c = run(c, [<astr_volname>])
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
%	This method is the main entry point to "running" an basac_process
%	class instance. It controls the main processing loop, viz. 
%
%		- reading image volumes 
%               - performing statistical ROI find
%               - performing a median filter
%               - analyzing for correlation
%
% PRECONDITIONS
%
%	o the basac_process class instance must be fully instantiated.
%
% POSTCONDITIONS
%
%
% NOTE:
%
% HISTORY
% 06 January 2009
% o Initial design and coding.
%

function correlation_plot(v_correlation, str_title)
    str_titleRep        = strrep(str_title, ' ', '');
    h = figure(8);
    plot(v_correlation);
    title(str_title);
    xlabel('Volume Slice Index');
    ylabel('Max Correlation ADC to ASL');
    grid on;
    if c.mb_imagesSave
      saveas(h, sprintf('%s.jpg', str_titleRep));
%        saveas(h, sprintf('%s.eps', str_titleRep));
      print('-depsc2', sprintf('%s.eps', str_titleRep));
    end
end

c.mstack_proc 	= push(c.mstack_proc, 'run');

c               = b0mask_read(c);
c               = asladc_read(c);
c               = ROI_findStatistically(c);
c               = ROI_medianFilter(c);
if c.mb_binarizeMasks
    c		= binarize(c);
end
c               = correlate(c);
c               = ROI_volsMeasure(c);
c               = correlation_report(c);

if c.mb_showVolumes
  figure(1); vol_imshow(c.mVn_ADC,      0);
  figure(2); vol_imshow(c.mVn_ASL,      0);   
  figure(3); vol_imshow(c.mV_ADCroiADC, 0);
  figure(4); vol_imshow(c.mV_ASLroiASL, 0);   
%    figure(5); vol_imshow(c.mV_ADCfilt);
%    figure(6); vol_imshow(c.mV_ASLfilt);
end

if c.mb_showScatter
    figure(7); 
    scatter(c.mv_ADCfilt, c.mv_ASLfilt);
end

if c.mb_showMaxCorrelation
    correlation_plot(c.mv_maxCorrelationPerSliceR,      ...
                    'Raw Correlation Profile for Single Subject');
    correlation_plot(c.mv_maxCorrelationPerSliceW,      ...
                    'Filtered Correlation Profile for Single Subject');
end

[c.mstack_proc, element] = pop(c.mstack_proc);

end