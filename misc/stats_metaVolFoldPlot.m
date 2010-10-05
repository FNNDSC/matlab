function [aM] = 	...
			stats_metaVolFoldPlot(av_GWI, av_WMF)
%
% NAME
%
%  function [aM] = stats_metaVolFoldPlot()
%
% ARGUMENTS
% INPUT
%
%	av_GWI		vector		Gray/White Index vector
%	av_WMF		vector		White Matter Folding vector
%
% OPTIONAL
%
% OUTPUTS
%	aM		matrix		av_GWI : av_WMF
%
% DESCRIPTION
%
%	'stats_metaVolFoldPlot' draws plots of the GWI and WMF indices for a
%	set of subjects
%
% PRECONDITIONS
%
%	o A set of directories branching from the working directory. These
%	  directories denote specific subjects and must be 'numeric' named -
%	  a good strategy is to use the subject age as a name.
%
% POSTCONDITIONS
%
%	o Plots are generated (and saved) of the GWI and WMF.
%
% SEE ALSO
%
% HISTORY
% 15 March 2007
% o Initial design and coding.
%
%


cell_dir	= ls09;
cols		= size(cell_dir, 2);
cell_subj	= cell_dir(1:cols);
cell_curvs	= {'Gray/White Index', 'White Matter Folding'};
cell_curvFile	= {'GWI', 'WMF'};
curv		= 0;
[rows cols]	= size(av_GWI);
aM		= zeros(rows, 2);
aM(:,1)		= av_GWI;
aM(:,2)		= av_WMF;
for ci=1:2
	h= 		figure('Position',[1 1 850 550]);
	curv=		curv + 1;
	plot(aM(:,ci));
	set(gca, 'XTickLabel', cell_subj, 'XTick', [1:15]);
	grid on
	title(sprintf('%s', cell_curvs{curv}));
	xlabel('subjects');
	str_epsFile=	sprintf('%s.eps', cell_curvFile{curv});
	str_jpgFile=	sprintf('%s.jpg', cell_curvFile{curv});
	print('-depsc2', 	str_epsFile);
	print('-djpeg', 	str_jpgFile);
end
