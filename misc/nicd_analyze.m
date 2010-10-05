function [av_f, av_F] = nicd_analyze(av_t, av_y, varargin)
%
% NAME
%
%  function [av_f, av_F] = nicd_analyze(av_t, av_y [,			...
%						astr_titleTD,		...
%						astr_xlabelTD,		...
%  						astr_ylabelTD,		...
%						astr_titleFD,		...
%						astr_xlabelFD,		...
%						astr_ylabelFD,		...
%						astr_imageFile,		...
%						af_hourlySample])
%
% ARGUMENTS
% INPUT
%	t		vector		time vector
%	y		vector		function vector
%
% OPTIONAL
%	astr_titleTD	string		title for the time domain plot
%	astr_xlabelTD	string		x-axis label for the time plot
%	astr_ylabelTD	string		y-axis label for the time plot
%	astr_titleFD	string		title fot the freq domain plot
%	astr_xlabelTD	string		x-axis label for the time plot
%	astr_ylabelTD	string		y-axis label for the time plot
%	astr_imageFile	string		The filename base (and extension) 
%					to use when saving images
%	af_hourlySample	float		number of samples taken per hour
%
% OUTPUT
%	f		vector		frequency values
%	F		vector		FFT
%
% DESCRIPTION
%
%	'nicd_analyze' performs a simple FFT analysis on its
%	input time <t> and function <y> vector arguments.
%
% PRECONDITIONS
%	o av_t is assumed to have units of *hours*.
%	o av_t and av_y should be *row* vectors.
%
% POSTCONDITIONS
%
%	o Returns <F> the mag FFT of the internal signal and <f> the frequency
%	  components.
%
% NOTE:
%
% HISTORY
% 12 September 2007
% o Initial design and coding.
%


LC		= 50;
RC		= 30;

str_titleTD	= 'Time domain plot';
str_xlabelTD	= 'Time (hours)';
str_ylabelTD	= 'Concentration';
str_titleFD	= 'Single-Sided Amplitude Spectrum of y(t)';
%  str_xlabelFD	= 'Frequency (millihertz)';
str_xlabelFD	= 'Oscillation (hours)';
str_ylabelFD	= '|FFT(y)|';
Fs_hr		= 1/(av_t(2) - av_t(1));
b_saveImage	= 0;

if(length(varargin))
    if(length(varargin) >= 1), 	str_titleTD 	= varargin{1};, end;
    if(length(varargin) >= 2), 	str_xlabelTD 	= varargin{2};, end;
    if(length(varargin) >= 3), 	str_ylabelTD 	= varargin{3};, end;
    if(length(varargin) >= 4), 	str_titleFD 	= varargin{4};, end;
    if(length(varargin) >= 5), 	str_xlabelFD 	= varargin{5};, end;
    if(length(varargin) >= 6), 	str_ylabelFD 	= varargin{6};, end;
    if(length(varargin) >= 7),	str_imageFile	= varargin{7}; 
				b_saveImage	= 1;,		end;
    if(length(varargin) >= 8), Fs_hr		= varargin{8};, end;
end


L		= length(av_t);
Fs		= Fs_hr/60/60;		% Sampling frequency: 	Hz
T		= 1/Fs;			% Sampling period: 	s
v_t1 		= (1:L)*T; 		% Time vector in units	s

h 		= figure(1);
cax		= newplot;
plot(cax, av_t, av_y);
set(cax, 'FontName', 'Helvetica', 'FontSize', 10, 'FontUnits', 'points');
title(str_titleTD);
xlabel(str_xlabelTD);
ylabel(str_ylabelTD);
grid;
if(b_saveImage), saveas(h, sprintf('time-%s', str_imageFile));
		 str_basename	= strtok(str_imageFile, '.');
		 str_epsFile	= sprintf('time-%s.eps', str_basename);
		 print('-depsc2', str_epsFile);
end

% Frequency analysis
NFFT 	= 2^nextpow2(v_t1);
%  NFFT	= length(v_t1);
v_Y 	= fft(av_y, NFFT)/L;
av_f 	= Fs/2*linspace(0,1,NFFT/2) * 2*pi;

% Plot single-sided amplitude spectrum
av_F	= 2*abs(v_Y(1:NFFT/2));
av_fs	= av_f * 1000;

av_fhr	= 1 ./ (av_f*3600);

str_fhr	= sprintf('%.2f|', av_fhr);
str_fhr = strrep(str_fhr, 'Inf', 'DC');
h	= figure(2);
cax	= newplot;
set(cax, 'FontName', 'Helvetica', 'FontSize', 13, 'FontUnits', 'points');
%  stem(cax, av_fs, av_F); 
stem(cax, av_F, 'LineWidth', 2, 'MarkerSize', 12, 'Color', 'k', 'MarkerFaceColor', 'k');
set(cax, 'XTickLabel', str_fhr, 'XTick', [1:length(av_fhr)]); 
grid;
title(str_titleFD)
xlabel(str_xlabelFD)
ylabel(str_ylabelFD)
if(b_saveImage), saveas(h, sprintf('freq-%s', str_imageFile));
		 str_basename	= strtok(str_imageFile, '.');
		 str_epsFile	= sprintf('freq-%s.eps', str_basename);
		 print('-depsc2', str_epsFile);
end


