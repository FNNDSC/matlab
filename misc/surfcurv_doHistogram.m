function [acell_table, acell_hist] = surfcurv_doHistogram(varargin)
%
% NAME
%
%	function [acell_table, acell_hist] = surfcurv_doHistogram(	...
%								[astr_hemi,
%								ab_sulcCurv,
%								ac_plotArgs,
%								astr_title,
%								astr_xlabel])
%
% ARGUMENTS
%
%	INPUT
%	astr_hemi	string (optional)	a string denoting the 
%						hemisphere to process: 
%						either 'lh' or 'rh'.
%						Default: 'lh'. 
%	ab_sulcCurv	bool (optional)		if TRUE, process the
%						'?h.curv' and '?h.sulc'
%						files as well.
%	ac_plotArgs	cell (optional)		arguments to pass to the 
%						curvs_plot() function.
%	astr_title	string (optional)	Final bar graph title string
%	astr_xlabel	string (optional)	Final bar graph x-label
%
%	OUTPUT
%	acell_table	cell			A cell structure containing
%						the individual table cell
%						matrices.
%	acell_hist	cell			A cell structure containing
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
% 07 July 2006
% o Initial design and coding.
%
% 14 July 2006
% o Expanded to 'curv' and 'sulc' files
% o External control over graph title
%
% 22 August 2006
% o Added mechanism to pass arguments to curvs_plot()
%
% 21 September 2007
% o Curvature pipeline generalisation
%

bins		= 1000;
b_normalize	= 1;
f_lower		= -1;
f_upper		= 1;
b_drawPlots	= 1;
b_yMinMax	= 0;
f_ymin		= 0;
f_ymax		= 0;

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
b_sulcCurv	= 0;
str_title	= 'Percentage negative curvature as function of wavelet spectral power';
str_xlabel	= 'Wavelet spectral power';

if length(varargin)
	str_hemi	= varargin{1};
	if length(varargin) >= 2
		b_sulcCurv	= varargin{2};
	end
	if length(varargin) >= 3
		if(length(varargin{3})) >= 6
			c_plotArgs	= varargin{3};
			bins		= c_plotArgs{1};
			b_normalize	= c_plotArgs{2};
			f_lower		= c_plotArgs{3};
			f_upper		= c_plotArgs{4};
			b_drawPlots	= c_plotArgs{5};
			b_animate	= c_plotArgs{6};
		end
		if(length(varargin{3})) == 8
			f_ymin		= c_plotArgs{7};
			f_ymax		= c_plotArgs{8};
			b_yMinMax	= 1;
		end
	end
	if length(varargin) >= 4
		str_title	= varargin{4};
	end
	if length(varargin) >= 5
		str_xlabel	= varargin{5};
	end
end

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