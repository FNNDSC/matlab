function [ax h1 h2] = adcasl_bar(varargin)

%
% INPUTS
%   OPTIONAL
%     v_YLim1           vector              limits on Y1-axis
%     YTicks1           int                 number of ticks on Y1 axis
%     v_YLim2           vector              limits on Y2-axis
%     Y_Ticks2          int                 number of ticks on Y2
%                                           axis
%     str_fileOut       string              stem for output file save/print
%

b_YLim1   = 0;
b_YLim2   = 0;
YTicks1   = 20;
YTicks2   = 20;
b_figSave = 0;

if length(varargin) >= 1
  if length(varargin{1})
    b_YLim1 = 1; v_YLim1 = varargin{1}; 
  end
end

if length(varargin) >= 2
  b_YTicks1 = 1;
  YTicks1 = varargin{2};
end

if length(varargin) >= 3
  if length(varargin{3})
    b_YLim2 = 1; v_YLim2 = varargin{3}; 
  end
end

if length(varargin) >= 4
  b_YTicks2 = 1;
  YTicks2 = varargin{4};
end

if length(varargin) >= 5
  b_figSave = 1;
  str_fileOut = varargin{5};
end

t5 = load('table5.txt');

y1 = t5(:,1); e1 = t5(:,2);
y2 = t5(:,3); e2 = t5(:,4);     
y3 = t5(:,5); e3 = t5(:,6);     
y4 = t5(:,7); e4 = t5(:,8);          

x   = 1:11;
x11 = x - 0.3;
x12 = x - 0.1;
x21 = x + 0.1;
x22 = x + 0.3;

M_X1 = [x11' x12'];
M_X2 = [x21' x22'];

s_Y1 = struct;
s_Y1.v_y1 = y1;
s_Y1.v_e1 = e1;
s_Y1.v_y2 = y2;
s_Y1.v_e2 = e2;
s_Y1.width = [0.2 0.20];
s_Y1.M_C = {
    [0 0 1] [135 206 250]./255
    [70 130 180]./255 [176 216 230]./255
    };
s_Y1.legendLocation = 'NorthWest';
s_Y1.legendNames = { 'ADC ROI', '\sigma(ADC ROI)', 'ADC nonROI', ...
                    '\sigma(ADC nonROI)'}';
s_Y1.YTicks = YTicks1;

s_Y2 = struct;
s_Y2.v_y1 = y3;
s_Y2.v_e1 = e3;
s_Y2.v_y2 = y4;
s_Y2.v_e2 = e4;
s_Y2.width = [0.2 0.20];
s_Y2.M_C = {
    [124 252 0]./255 [152 251 152]./255
    [46 139 87]./255 [143 188 143]./255
    };
s_Y2.legendLocation = 'NorthEast';
s_Y2.legendNames = { 'ASL-CBP ROI', '\sigma(ASL-CBP ROI)', 'ASL-CBP nonROI', ...
                    '\sigma(ASL-CBP nonROI)'}';
s_Y2.YTicks = YTicks2;

figure;
bar2plot(M_X1, s_Y1);
hold on;
bar2plot(M_X2, s_Y2);

xlabel('Subject ID');
title('ADC and ASL-CBP values within and without ROIs');

[ax h1 h2] = plotyy(M_X1, s_Y1, M_X2, s_Y2, 'bar2plot');

grid minor;
set(get(ax(1), 'Ylabel'), 'String', 'ADC [10^{-6}mm^2/s]');
set(get(ax(2), 'Ylabel'), 'String', 'ASL-CBP [ml / 100g / min]');
set(gca, 'XTick', 1:length(x));

if b_YTicks1
  v_y1max = get(ax(1), 'YLim'); y1max = v_y1max(2);
  set(ax(1), 'YTick', 0:y1max/s_Y1.YTicks:y1max);
end

if b_YTicks2
  v_y2max = get(ax(2), 'YLim'); y2max = v_y2max(2);
  set(ax(2), 'YTick', 0:y2max/s_Y2.YTicks:y2max);
end

if b_YLim1
  set(ax(1), 'YLim', v_YLim1);
end
if b_YLim2
  set(ax(2), 'YLim', v_YLim2);
end

if b_figSave
  str_epsFile     = sprintf('%s.eps', str_fileOut);
  str_jpgFile     = sprintf('%s.jpg', str_fileOut);
  str_pdfFile     = sprintf('%s.pdf', str_fileOut);
  lprintf(40, 'Saving %s', str_epsFile); print('-depsc2', ...
                                               str_epsFile);
  lprintf(40, '[ ok ]\n');
  lprintf(40, 'Saving %s', str_jpgFile); print('-djpeg', ...
                                               str_jpgFile);
  lprintf(40, '[ ok ]\n');
  lprintf(40, 'Saving %s', str_pdfFile); print('-dpdf', ...
                                               str_pdfFile);
  lprintf(40, '[ ok ]\n');
end
