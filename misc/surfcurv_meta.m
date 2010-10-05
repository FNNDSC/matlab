function [cM] = surfcurv_meta(varargin)
%
% NAME
%
%  function [cM] = surfcurv_meta([av_stages,		...
%				  astr_hemi,		...
%				  av_group,		...
%				  ac_line,		...
%				  ab_plotArgsHist])
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%	av_stages		vector	stages of the pipeline to process
%	astr_hemi		string	'rh' | 'lh' - hemisphere to process
%	av_group		vector	subject grouping (see below)
%	ac_line			cell	plot specification per group
%	ac_plotArgsHist		cell	plot args for histogram analysis
%
% OUTPUTS
%	cM			cell	cell array of stats data, organized
%					per curvature type
%
% DESCRIPTION
%
%	'surfcurv_meta' is a high-level routine that serves as one of
%	the main entry points to a SURFace CURVature processing pipeline.
%
%	The first stage of the pipeline is 'surfcurv_doHistogram(...)' 	
% 	which is hard coded with a list of principle curvature maps to process. 
%	As the name suggests, this stage processes a curvature map and 
%	returns a histogram distrubution of the curvature values in the
%	map. If specified by user flags, this stage will also plot
%	the histograms across its input subjects of the particular curvature
%	it is processing.
%
%	Once histograms have been processed, the next stage in the pipeline
%	analyzes the histograms to determine their centroids. The negative
%	and positive centroids are considered separately.
%
%	The third step in the pipeline is to analyze the curvature maps
%	themselves, and generate/save plots of the mean and std (postive
%	and negative curvature values are also considered separately, as
%	is the absolute curvature value).
%
%	The fourth pipeline step analyzes the bending energy profile of
%	the surfaces. These profiles are also plotted/saved.
%
% STAGES
%
%	The <av_stages> is a vector of bits in which bit positions in MatLAB
%	order toggle a particular stage ON or OFF. There are four stages, 
%	which would be indicated by av_stages = [ 1 1 1 1].
%
%	STAGE		DESCRIPTION
%	  1		THIS STAGE IS COMPULSORY!
%			Process a histogram analysis on all the curvature
%			maps of all the subjects in the working directory.
%	  2		Process centroids of the histograms.
%	  3		Generate mean/std plots of curvature maps across
%			all subjects.
%	  4		Process a bending energy profile of the area
%			normalized BE function -- table generation
%	  5		Process a bending energy profile of the area
%			normalized BE function -- table plotting
%
% PRECONDITIONS
%
%	o A set of directories branching from the working directory. These
%	  directories denote specific subjects and must be 'numeric' named -
%	  a good strategy is to use the subject age as a name. This has the
%	  added benefit of a 'natural' order in processing - increasing
%	  subjects have increasing age.
%
%    	o The ac_plotArgsHist = 
%		{ <bins>, <b_normalize>, 
%		  <f_leftFilter>, <f_rightFilter>,
%		  <b_plot>, <b_animate>}
%
% POSTCONDITIONS
%
%	o Depending on the actual stage being processed, different
%	  outputs (either text tables and/or graphs) are generated.
%
% SEE ALSO
%
% HISTORY
% 13 September 2007
% o Adaptation / expansion from 'stats_meta.m'.
%
%

 %%
% Nested functions: START
%%

   function sys_print(astr)
        fprintf(1, sprintf('%s %s', syslog_prefix(), astr));
    end

%%
% Nested functions: END
%%

str_funcName	= 'surfcurv_meta';

str_hemi 	= 'rh';
v_stages	= [1 1 1 1];	% Turn on ALL stages
c_line		= { '-or'}; 	% Defaults to single spec, single group
v_group		= size(ls09, 2);% Defaults to number of numeric sub-directories
				% in current path

c_plotArgsHist	= { 1000, 1, -1.5, 1.5, 0, 0 };		% no plots, no animate


if(length(varargin) >= 1), v_stages 		= varargin{1};, end;
if(length(varargin) >= 2), str_hemi	  	= varargin{2};, end;
if(length(varargin) >= 3), v_group 	  	= varargin{3};, end;
if(length(varargin) >= 4), c_line 	  	= varargin{4};, end;
if(length(varargin) >= 5), c_plotArgsHist 	= varargin{5};, end;

sys_print(sprintf('| %s | stage 1 | START\n', str_funcName));
b_processCurvSulc	= 0;
[cell_table, cell_hist]	= surfcurv_doHistogram(	str_hemi, 		...
						b_processCurvSulc,	...
						c_plotArgsHist);
sys_print(sprintf('| %s | stage 1 | END\n', str_funcName));
numPlots	= length(cell_table);
cM		= cell(1, numPlots);

if(v_stages(2))
    sys_print(sprintf('| %s | stage 2 | START\n', str_funcName));
    c_plotArgs	= { v_group, c_line};
    [M_tableK]	= centroids_process(cell_hist{1}, c_plotArgs, 	...
					sprintf('%s-K', str_hemi));
    [M_tableH]	= centroids_process(cell_hist{2}, c_plotArgs, 	...
					sprintf('%s-H', str_hemi));
    [M_tablek1]	= centroids_process(cell_hist{3}, c_plotArgs, 	...
					sprintf('%s-k1', str_hemi));
    [M_tablek2]	= centroids_process(cell_hist{4}, c_plotArgs, 	...
					sprintf('%s-k2', str_hemi));
    [M_tableS]	= centroids_process(cell_hist{5}, c_plotArgs, 	...
					sprintf('%s-S', str_hemi));
    [M_tableC]	= centroids_process(cell_hist{6}, c_plotArgs, 	...
					sprintf('%s-C', str_hemi));
    sys_print(sprintf('| %s | stage 2 | END\n', str_funcName));
end

if(v_stages(3))
    sys_print(sprintf('| %s | stage 3 | START\n', str_funcName));
    T		= cell_table{1};
    [rows cols]	= size(T);
    for i=1:numPlots
	cM{i}	= zeros(rows, 9);
	cM{i}(:,1)= cell_table{i}(:,1);
	cM{i}(:,2)= cell_table{i}(:,3);
	cM{i}(:,3)= cell_table{i}(:,9);
	cM{i}(:,4)= cell_table{i}(:,10);
	cM{i}(:,5)= cell_table{i}(:,11);
	cM{i}(:,6)= cell_table{i}(:,12);
	cM{i}(:,7)= cell_table{i}(:,13);
	cM{i}(:,8)= cell_table{i}(:,14);
	cM{i}(:,9)= cell_table{i}(:,15);
    end

    cell_dir	= ls09;
    cols	= size(cell_dir, 2);
    cell_subj	= cell_dir(1:cols);
    cell_curvs	= {'K', 'H', 'k_1', 'k_2', 'S', 'C'};
    curv	= 0;
    cell_lSpec1	= {'-sb', '-dg', '-or', '-^c', '-*m', '-vy', '-xk'};
    cell_lSpec2 = {'-dg', '-or'};
    for ci=1:numPlots
	M_allstats		= cM{ci}(:,3:9);
	[subjects, plotParms]	= size(M_allstats);
	M_meanSigma		= cM{ci}(:,4:5);
	h= 		figure('Position',[1 1 850 550]);
	curv=		curv + 1;
	if(strcmp(cell_curvs{curv},'S')||strcmp(cell_curvs{curv},'C'))
%  	    plot(cM{ci}(:,4:5), cell_lSpec2);
	    hold on;
	    for j=1:2
%  	      plot(M_meanSigma(:,j), cell_lSpec2{j});
	      plot(M_meanSigma(:,j), cell_lSpec2{j}, 			...
			'MarkerEdgeColor', 'black',			...
			'MarkerFaceColor', 'black');
	    end
	    legend('mean(x)', '\sigma(x)',				...
		   'Location', 'SouthOutside', 'Orientation', 'horizontal');
	else
	    hold on;
	    for j=1:plotParms
%  	      plot(M_allstats(:,j), cell_lSpec1{j});
	      plot(M_allstats(:,j), cell_lSpec1{j},			...
			'MarkerEdgeColor', 'black',			...
			'MarkerFaceColor', 'black');
	    end
	    legend('mean(|x|)','mean(x)', '\sigma(x)', 'mean(+x)', 	...
		   '\sigma(+x)', 'mean(-x)', '\sigma(-x)',		...
		   'Location', 'SouthOutside', 'Orientation', 'horizontal');
	end
	set(gca, 'XTickLabel', cell_subj, 'XTick', [1:cols]);
	grid on
	title(sprintf('%s-%s: stats', str_hemi, cell_curvs{curv}));
	xlabel('subjects');
	str_epsFile=	sprintf('%s-%s.eps', str_hemi, cell_curvs{curv});
	print('-depsc2', str_epsFile);
	% To convert the eps into png, use 'eps2png' 
    end
    sys_print(sprintf('| %s | stage 3 | END\n', str_funcName));
end

if(v_stages(4))
    sys_print(sprintf('| %s | stage 4 | START\n', str_funcName));
    str_curvFunc = 'S';
    % Note automated processing might fail and adult subjects might
    % require processing without 'discrete' curvature flag set.
    str_cmd = sprintf(							 ...
	'principleCurves_doTable.bash -v 10 -T %s -H rh -i Norm [0-9]*', ...
	str_curvFunc);
    unix(str_cmd, '-echo');
    sys_print(sprintf('| %s | stage 4 | END\n', str_funcName));
end

if(v_stages(5))
    sys_print(sprintf('| %s | stage 5 | START\n', str_funcName));
    str_curvFunc = 'S';
    str_table = sprintf('%s-%s-Norm-highPassFilterGaussian-1.5.tab', 	 ...
			str_hemi, str_curvFunc);
    [cM] = stats_BE(str_table, 6, 0);
    sys_print(sprintf('| %s | stage 5 | END\n', str_funcName));
end

end