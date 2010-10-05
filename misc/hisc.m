function [aviFFT_curvK1, aviFFT_curvK2, aviFFT_curvK, aviFFT_curvH] = 	...
			hisc(varargin)
%
% NAME
%
%  function [avifft_K1, avifft_K1, avifft_K1, avifft_K1,] = 		...
%  				hisc(					...
%			[astr_fileStem 		= 'rh.smoothwm.',	...
%			ab_scatterPlotShow	= 1,			...
%			ab_histogramPlotShow	= 1)
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%	astr_fileStem		string		filestem to use.
%	ab_scatterPlotShow	bool		show scatter plot.
%	ab_histogramPlotShow	bool		show histogram plot.
%
% OUTPUTS
%	-void-
%
% DESCRIPTION
%
%	'hisc' denotes a histogram/scatter function. It reads in two
%	files, <astr_fileStem>K1 and <astr_fileStem>K2. These are
%	spatial vectors defining curvature on a surface. 
%
%	This script calls an inverse FFT on these spatial vectors,
%	and draws a histogram (of absolute complex) and a complex
%	scatter graph.
%
% PRECONDITIONS
%
%	o <astr_fileStem>{K1,K2} must exist.
%
% POSTCONDITIONS
%
%	o Depending on the bool flags, a scatter and/or histogram
%	  plot of the iFFT of the input curves is generated.
%
% SEE ALSO
%
% HISTORY
% 05 December
% o Initial design and coding.
%
%

global str_histogramColor;

%%%%%%%%%%%%%% 
%%% Nested functions
%%%%%%%%%%%%%% 
	function error_exit(	str_action, str_msg, str_ret)
		fprintf(1, '\tFATAL:\n');
		fprintf(1, '\tSorry, some error has occurred.\n');
		fprintf(1, '\tWhile %s,\n', str_action);
		fprintf(1, '\t%s\n', str_msg);
		error(str_ret);
	end

	function vprintf(level, str_msg)
	    if verbosity >= level
		fprintf(1, str_msg);
	    end
	end

%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 

str_fileStem	= 'rh.smoothwm';
b_scatterPlot	= 1;
b_histogramPlot	= 1;

if length(varargin)
    str_fileStem	= varargin{1};
    if length(varargin) >= 2
	b_scatterPlot	= varargin{2};
    end
    if length(varargin)	>= 3
	b_histogramPlot	= varargin{3};
    end
end

str_dir=pwd;
fprintf(1, 'Current dir:\n%s\n', str_dir);
fprintf(1, sprintf('%40s', 'Reading K1 curvature'));
[v_curvK1, fnum] 	= read_curv(sprintf('%s.K1', str_fileStem));
fprintf(1, sprintf('%40s\n', 	'[ ok ]'));
fprintf(1, sprintf('%40s', 'Reading K2 curvature'));
[v_curvK2, fnum] 	= read_curv(sprintf('%s.K2', str_fileStem));
fprintf(1, sprintf('%40s\n', 	'[ ok ]'));
fprintf(1, sprintf('%40s', 'Reading K curvature'));
[v_curvK, fnum] 	= read_curv(sprintf('%s.K', str_fileStem));
fprintf(1, sprintf('%40s\n', 	'[ ok ]'));
fprintf(1, sprintf('%40s', 'Reading H curvature'));
[v_curvH, fnum] 	= read_curv(sprintf('%s.H', str_fileStem));
fprintf(1, sprintf('%40s\n', 	'[ ok ]'));

aviFFT_curvK1 		= ifft(v_curvK1);
aviFFT_curvK2 		= ifft(v_curvK2);
aviFFT_curvK 		= ifft(v_curvK);
aviFFT_curvH 		= ifft(v_curvH);

str_path	= pwd;
str_thisDir	= basename(str_path);
if b_scatterPlot
    h = figure(1);
    fprintf(1, sprintf('%40s', 'K1, K2 scatter frequency'));
    scatter(real(aviFFT_curvK1), imag(aviFFT_curvK1), 5, 'r')
    hold on
    scatter(real(aviFFT_curvK2), imag(aviFFT_curvK2), 5, 'b')
    axis auto;
    hold off;
    grid;
    title(sprintf('Complex frequency plot of %s K1 (red), K2 (blue)', str_thisDir));
    fprintf(1, sprintf('%40s\n', 	'[ ok ]'));
    saveas(h, 'scatter_K1K2.jpg');
    saveas(h, 'scatter_K1K2.eps');

%      h = figure(2);
%      fprintf(1, sprintf('%40s', 'K, H scatter frequency'));
%      scatter(real(aviFFT_curvK), imag(aviFFT_curvK), 5, 'r')
%      hold on
%      scatter(real(aviFFT_curvH), imag(aviFFT_curvH), 5, 'b')
%      axis auto;
%      hold off;
%      grid;
%      title(sprintf('Complex frequency plot of %s K (red), H (blue)', str_thisDir));
%      fprintf(1, sprintf('%40s\n', 	'[ ok ]'));
%      saveas(h, 'scatter_KH.jpg');
%      saveas(h, 'scatter_KH.eps');

end

if b_histogramPlot
    h = figure(3);
    fprintf(1, sprintf('%40s', 'K1, K2 complex freq histogram'));
    FK1K2	= [ [aviFFT_curvK1]' [aviFFT_curvK2]'];
    FK1 	= [ [aviFFT_curvK1]']; 
    FK2 	= [ [aviFFT_curvK2]']; 
    absFK1K2 	= abs(FK1K2);
    absFK1 	= abs(FK1);
    absFK2 	= abs(FK2);
    str_histogramColor	= 'r';
    histogram(absFK1, 1000, 1);
    hold on;
    str_histogramColor	= 'g';
    histogram(absFK2, 1000, 1);
    axis auto;
    hold off; 
    grid;
    title(sprintf('Histogram of absolute complex frequency for %s K1 (red), K2 (black)', str_thisDir));
    fprintf(1, sprintf('%40s\n', 	'[ ok ]'));
    saveas(h, 'hist_K1K2.jpg');
    saveas(h, 'hist_K1K2.eps');

    h = figure(4);
    fprintf(1, sprintf('%40s', 'K, H complex freq histogram'));
    FKH 	= [ [aviFFT_curvK]' [aviFFT_curvH]'];
    FK 		= [ [aviFFT_curvK]'];
    FH	 	= [ [aviFFT_curvH]'];
    absFKH 	= abs(FKH);
    absFK 	= abs(FK);
    absFH 	= abs(FH);
    str_histogramColor	= 'r';
    histogram(absFK, 1000, 1);
    hold on;
    str_histogramColor	= 'g';
    histogram(absFH, 1000, 1);
    axis auto;
    hold off;
    grid;
    title(sprintf('Histogram of absolute complex frequency for %s K (red), H (black)', str_thisDir));
    fprintf(1, sprintf('%40s\n', 	'[ ok ]'));
    saveas(h, 'hist_KH.jpg');
    saveas(h, 'hist_KH.eps');
end

end