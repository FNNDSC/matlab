function c = surfcurv_doHistogram(c, varargin)
%
% NAME
%
%	function [c] = surfcurv_doHistogram( [astr_hemi = 'rh'])
%
% ARGUMENTS
%
%	INPUT
%	astr_hemi	string (optional)	a string denoting the 
%						hemisphere to process: 
%						either 'lh' or 'rh'.
%						Default: 'rh'.
%
%	OUTPUT - Class 'c' internals:
%	c.mcell_table	cell			A cell structure containing
%						the individual table cell
%						matrices.
%	c.mcell_hist	cell			A cell structure containing
%						the individual histogram
%						data for each curv processed.
%
% DESCRIPTION
%
%	'surfcurv_doHistogram' is a simple wrapper that drives two underlying
%	engines to process curvatures. The outputs of these engines are captured
%	into a cell array structure, and if specified, are also plotted. 
%
%	These engines are a histogram analysis process ('curvs_plot(...)') and
%	a simple statistical analysis process ('lzg_summary(...)').
%
% PRECONDITIONS
%
%	o Sub directories contain the curvature files that are read.
%	o If the ac_plotArgs cell does not contain 5 elements corresponding
%	  to {[bins], [b_normalize], [f_lower], [f_upper], [b_drawPlots]} it is
%	  ignored. If the <f_lower> and/or <f_upper> are not numeric, they are 
%	  ignored.
% 
% SEE ALSO
%	o curvs_plot.m
%	o lzg_summary.m
%
% HISTORY
% 23 September 2009
% o Initial design and coding -- adapting from stand-alone non-class version.
%

bins		= c.m_histBins;
b_normalize	= c.mb_histNormalize;
f_lower		= c.mf_lowerLimit;
f_upper		= c.mf_upperLimit;
b_drawPlots	= c.mb_drawHistPlots;
b_yMinMax	= c.mb_yMinMax;
f_ymin		= c.mf_ymin;
f_ymax		= c.mf_ymax;

%%%%%%%%%%%%%% 
%%% Nested functions
%%%%%%%%%%%%%% 

	function [V_col, cell_table, cell_hist]	= ...
		    curv_process(str_curvFile, cellIndex, cell_table, cell_hist)
		fprintf(1, '\t%s\n', str_curvFile);
		if b_yMinMax 
		    [cell_curv, cell_n, cell_dirnames] 	= ...
		    curvs_plot(	str_curvFile,		... 	
				bins, 	  		...
				b_normalize, 		...
				f_lower, f_upper, 	...
				b_drawPlots,		...
				b_animate,		...
				f_ymin, f_ymax);
		else
		    [cell_curv, cell_n, cell_dirnames] 	= ...
		    curvs_plot(	str_curvFile,		... 	
				bins, 	  		...
				b_normalize, 		...
				f_lower, f_upper, 	...
				b_drawPlots,		...
				b_animate);
		end
		[M_table] 		= lzg_summary(cell_curv, cell_n, 1, cell_dirnames);
		cell_table{cellIndex}	= M_table;
		cell_hist{cellIndex}	= cell_n;
		V_col			= M_table(:, 1);
		fprintf(1, '\n')
	end

%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 


str_hemi	= 'lh';


str_title	= 'Percentage negative curvature as function of wavelet spectral power';
str_xlabel	= 'Wavelet spectral power';


cellOffset 	= 0;
baseNumCurvs	= 6;
if b_sulcCurv
	cM		= cell(1, baseNumCurvs+2);
	acell_table	= cell(1, baseNumCurvs+2);
	acell_hist	= cell(1, baseNumCurvs+2);
	cellOffset	= 2;
	str_file = sprintf('%s.curv', str_hemi);
	[crv, acell_table, acell_hist] = ...
			curv_process(str_file, 1, acell_table, acell_hist);

	str_file = sprintf('%s.sulc', str_hemi);
	[slc, acell_table, acell_hist] = ...
			curv_process(str_file, 2, acell_table, acell_hist);
else
	cM		= cell(1, baseNumCurvs);
	acell_table	= cell(1, baseNumCurvs);
	acell_hist	= cell(1, baseNumCurvs);
end



str_file = sprintf('%s.smoothwm.K', str_hemi);
[K, acell_table, acell_hist] = ...
		curv_process(str_file, 1+cellOffset, acell_table, acell_hist);

str_file = sprintf('%s.smoothwm.H', str_hemi);
[H, acell_table, acell_hist] = ...
		curv_process(str_file, 2+cellOffset, acell_table, acell_hist);

str_file = sprintf('%s.smoothwm.K1', str_hemi);
[k2, acell_table, acell_hist] = ...
		curv_process(str_file, 3+cellOffset, acell_table, acell_hist);

str_file = sprintf('%s.smoothwm.K2', str_hemi);
[k1, acell_table, acell_hist] = ...
		curv_process(str_file, 4+cellOffset, acell_table, acell_hist);

str_file = sprintf('%s.smoothwm.S', str_hemi);
[S, acell_table, acell_hist] = ...
		curv_process(str_file, 5+cellOffset, acell_table, acell_hist);

str_file = sprintf('%s.smoothwm.C', str_hemi);
[C, acell_table, acell_hist] = ...
		curv_process(str_file, 6+cellOffset, acell_table, acell_hist);


%
% Create a family of summary text files in root directory:
%	- lzg.<i>.txt		: percentage +/-
%	- stats.<i>.txt		: mean, abs_mean, std, pmean, pstd, nmean, nstd 
%
T		= acell_table{1};
[rows cols]	= size(T);
for i=1:length(cM)
	format short
	cM{i}		= zeros(rows, 11);
	cM{i}(:,1)	= acell_table{i}(:,1);
	cM{i}(:,2)	= acell_table{i}(:,2);
	cM{i}(:,3)	= acell_table{i}(:,3);
	cM{i}(:,4)	= acell_table{i}(:,9);
	cM{i}(:,5)	= acell_table{i}(:,10);
	cM{i}(:,6)	= acell_table{i}(:,11);
	cM{i}(:,7)	= acell_table{i}(:,12);
	cM{i}(:,8)	= acell_table{i}(:,13);
	cM{i}(:,9)	= acell_table{i}(:,14);
	cM{i}(:,10)	= acell_table{i}(:,15);
	cM{i}(:,11)	= acell_table{i}(:,8);
	M_lgz		= cM{i}(:,1:3);
	M_stats		= cM{i}(:,4:11);
	str_lgz		= sprintf('%s-lgz.%d.txt', str_hemi, i);
	str_stats	= sprintf('%s-stats.%d.txt', str_hemi, i);
	fid_lgz		= fopen(str_lgz, 'w');
	fid_stats	= fopen(str_stats, 'w');
	fprintf(fid_lgz, '%f\t%f\t%f\n', M_lgz');
	fprintf(fid_stats, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', M_stats');
        fclose(fid_lgz);
        fclose(fid_stats);
end

if b_drawPlots
    figure;
    if b_sulcCurv
        T 	= [crv slc K H k2 k1 S C];
    else
        T 	= [K H k2 k1 S C];
    end
    [rows cols]	= size(T);
    t=0:rows-1;
    bar(t, T);
    if b_sulcCurv
        legend('curv', 'sulc', 'K', 'H', 'k1', 'k2', 'S', 'C');
    else
        legend('K', 'H', 'k1', 'k2', 'S', 'C');
    end
    title(str_title);
    xlabel(str_xlabel);
    ylabel('Fraction negative curvature');
end

end