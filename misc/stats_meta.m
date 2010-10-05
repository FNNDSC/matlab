function [cM] = 	...
			stats_meta(varargin)
%
% NAME
%
%  function [] = stats_meta(<astr_hemi>)
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%	astr_hemi	string		'rh' | 'lh' - hemisphere to process
%
% OUTPUTS
%	cM		cell		cell array of stats data, organized
%					per curvature type
%
% DESCRIPTION
%
%	'stats_meta' is a high-level routine that calls several underlying
%	functions to process and plot statistical data from a set of
%	subject named directories containing curvature data.
%
% PRECONDITIONS
%
%	o A set of directories branching from the working directory. These
%	  directories denote specific subjects and must be 'numeric' named -
%	  a good strategy is to use the subject age as a name.
%
% POSTCONDITIONS
%
%	o The 'meta' function runs through the entire curvature processing
%	  chain, culminating in a series of plots for each main curvature
%	  group.
%
% SEE ALSO
%
% HISTORY
% 05 December
% o Initial design and coding.
%
%

str_hemi = 'rh';

if length(varargin)
	str_hemi = varargin{1};
end

c_plotArgsHist= { 1000, 1, -1.5, 1.5, 0, 0 };		% no plots, no animate
[cell_table, cell_hist]= waveletbars(str_hemi, 1, c_plotArgsHist);
c_line= { '-or', '-sm', '-^b' };
v_group= [9 3 3];
c_plotArgs= { v_group, c_line};

numPlots	= length(cell_table);
cM=cell(1,numPlots);
T=cell_table{1};
[rows cols]=size(T);
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

[M_tableCurv]= 	centroids_process(cell_hist{1}, c_plotArgs, sprintf('%s-curv', str_hemi));
[M_tableSulc]= 	centroids_process(cell_hist{2}, c_plotArgs, sprintf('%s-sulc', str_hemi));
[M_tableK]= 	centroids_process(cell_hist{3}, c_plotArgs, sprintf('%s-K', str_hemi));
[M_tableH]= 	centroids_process(cell_hist{4}, c_plotArgs, sprintf('%s-H', str_hemi));
[M_tablek1]= 	centroids_process(cell_hist{5}, c_plotArgs, sprintf('%s-k1', str_hemi));
[M_tablek2]= 	centroids_process(cell_hist{6}, c_plotArgs, sprintf('%s-k2', str_hemi));
[M_tableS]= 	centroids_process(cell_hist{7}, c_plotArgs, sprintf('%s-S', str_hemi));
[M_tableC]= 	centroids_process(cell_hist{8}, c_plotArgs, sprintf('%s-C', str_hemi));


[status,str_dirAll]= system('/bin/ls -d [0-9]* | sort -n');
str_start= pwd;
% Create a cell array of the directory names
ndir= 1;
[str_dir str_rem]= strtok(str_dirAll);
cell_dir{ndir}= str_dir;
while length(str_rem)
	[str_dir str_rem]= strtok(str_rem);
	ndir= ndir + 1;
	cell_dir{ndir}= str_dir;
end

cols=		ndir - 1;
cell_subj=	cell_dir(1:cols);
cell_curvs=	{'K', 'H', 'k_1', 'k_2', 'S', 'C'};
curv=		0;
cell_lineSpec=	{'+', 'o',  '*',  'x',   's', 'd'};
for ci=3:8
	h= 		figure('Position',[1 1 850 550]);
	curv=		curv + 1;
	plot(cM{ci}(:,3:9));
	set(gca, 'XTickLabel', cell_subj, 'XTick', [1:cols]);
	grid on
	legend(	'mean(|x|)','mean(x)', '\sigma(x)', 'mean(+x)', 	...
		'\sigma(+x)', 'mean(-x)', '\sigma(-x)',			...
		'Location', 'SouthOutside', 'Orientation', 'horizontal' );
	title(sprintf('%s-%s: stats', str_hemi, cell_curvs{curv}));
	xlabel('subjects');
	str_epsFile=	sprintf('%s-%s.eps', str_hemi, cell_curvs{curv});
	print('-depsc2', str_epsFile);
	% To convert the eps into png, use 'eps2png' 
end
