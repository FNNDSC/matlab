function [cM] = 	...
			stats_metaFold(varargin)
%
% NAME
%
%  function [cM] = stats_metaFold()
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%
% OUTPUTS
%	cM		cell		cell array of stats data, organized
%					per curvature type
%
% DESCRIPTION
%
%	'stats_metaFold' draws plots of the GWI and WMF indices for a set of
%	subjects
%
% PRECONDITIONS
%
%	o A set of directories branching from the working directory. These
%	  directories denote specific subjects and must be 'numeric' named -
%	  a good strategy is to use the subject age as a name.
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

c_plotArgsHist= { 1000, 1, -1.5, 1.5, 0, 0 };		% no plots, no animate
[cell_table, cell_hist]= waveletbars('rh', 1, c_plotArgsHist);
c_line= { '-or', '-sm', '-^b' };

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
	legend(	'mean(abs(x))','mean(x)', '\sigma(x)', 'mean(+x)', 	...
		'\sigma(+x)', 'mean(-x)', '\sigma(-x)',			...
		'Location', 'SouthOutside', 'Orientation', 'horizontal' );
	title(sprintf('%s: stats', cell_curvs{curv}));
	xlabel('subjects');
	str_epsFile=	sprintf('%s.eps', cell_curvs{curv});
	print('-depsc2', str_epsFile);
end
