function [acell_IA, acell_vframe, acell_hist, acell_bar] = 		...
						kentron_volAnBatch(	...
							astr_findExpr,	...
							varargin)
% NAME
%
%  function [acell_IA, acell_vframe, acell_hist, acell_car] = 
%						kentron_volAnBatch(	...
%					astr_findExpr	[,		...
%					ab_animate, 			...
%					a_slabDir=<direction>,		...
%					a_inPlaneDir=<direction>])
%
%
% ARGUMENTS
% input
%	astr_findExpr		string		a find friendly expression that
%						defines the volumes to process.
%
% optional
%	ab_animate		bool		if true (default), show each 
%						plot in the same window. This
%						has the effect of creating an
%						animation illusion
%	a_slabDir		int		plane direction to analyze:
%							1 - row
%							2 - col
%							3 - slice
%	a_inPlaneDir		int		in-plane direction to analyze:
%						1 - rowDir (i.e. across rows
%							or "up/down")
%						2 - colDir (i.e. across cols
%							or "left/right")
%
% outputs
%	acell_IA		cell		cell structure of processed 
%						intenisty matrices.
%	acell_vframe		cell		cell structure of processed
%						volumetric frames.
%	acell_hist		cell		cell structure of processed 
%						histograms.
%	acell_bar		cell		cell structure of collapsed
%						means of each IA.
%
% DESCRIPTION
%
%	'kentron_volAnBatch' batch runs 'kentron_volAn' on volumes that
%	satisfy the <astr_findExpr>. Data from the underlying kentron_volAn()
%	functions are stored in cell structures for downstream processing.
%
% PRECONDITIONS
%
%	o Input volumes are MGH format.
%
% POSTCONDITIONS
%
%	o Volume analysis is presented in both a returned volume and a 3D mesh.
%
% SEE ALSO
%
%
% HISTORY
%
% 18 August 2006
% o Initial design and coding.
%
% 05 October 2006
% o Added ab_animate
% o Changed meaning of returned values from kentron_volAn()
%

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

b_animate	= 1;
slabDir		= 3; 		% slice direction
inPlaneDir	= 1;		% row direction


if length(varargin)
	b_animate	= varargin{1};
	if length(varargin) >= 2
	    slabDir	= varargin{2};
	end
	if length(varargin) >= 3
	    inPlaneDir 	= varargin{3};
	end
end

% find all hits defined by <astr_findExpr>
startDir		= cd;
[status, str_dirAll]	= unix(sprintf('find . -name "%s"', astr_findExpr));

% Create a cell array of the directory names
ndir			= 1;
[str_dir str_rem]	= strtok(str_dirAll);
cell_dir{ndir}		= str_dir;
while length(str_rem)
	[str_dir str_rem]	= strtok(str_rem);
	ndir			= ndir + 1;
	cell_dir{ndir}		= str_dir;
end

% Create string array from results - each directory will be a separate element:
cols		= ndir - 1;
acell_IA	= cell(1, cols);
acell_vframe	= cell(1, cols);
acell_hist	= cell(1, cols);
acell_bar	= cell(1, cols);
for i = 1:cols
    str_fileName			= cell_dir{i};
    [acell_IA{i}, acell_vframe{i}]	= kentron_volAn(str_fileName, slabDir, inPlaneDir);
    f_mean				= mean(mean(acell_IA{i}));
    f_std				= std(std(acell_IA{i}));
    fprintf(1, '%s: intenisty analysis - mean: %f, std: %f\n', ...
		str_fileName, f_mean, f_std);
    if b_animate
	j = 1;
    else
	j = i;
    end

    % Intensity analysis mesh
    h = figure(j*10) ; mesh(acell_IA{i}); 
    title(sprintf('%s: 3D Intensity analysis mesh', str_fileName));
    saveas(h, sprintf('%s-3D_intensity_analysis.jpg', str_fileName));

    % Center slice from volume frame
    sv = size(acell_vframe{i});
    centerSlab = round(sv(4)/2);
    h = figure (j*10+1); 
    imshow(acell_vframe{i}(:,:,:,centerSlab), [], 'InitialMagnification', 300);
    title(sprintf('%s: Center slice from image volume', str_fileName));
    saveas(h, sprintf('%s-center_slice.jpg', str_fileName));

    % Process volume data as a histogram
    volumeSize	= prod(sv);
    v_image	= reshape(acell_vframe{i}, 1, volumeSize);
    h = figure(j*10+2);
%      acell_hist{i}	= histogram(v_image, 1000, 1, 50, 250, 0, 0.7);
    v_image = v_image ./ max(v_image);
    acell_hist{i}	= histogram(v_image, 1000, 1, 0, 1);
    grid on
    title(sprintf('%s: Histogram intensity plot', str_fileName));
    saveas(h, sprintf('%s-histogram_analysis.jpg', str_fileName));

    h = figure(j*10+3);
    M 	= mean(acell_IA{i});
    bar(M);
    grid on
    title(sprintf('%s: Average spatial intensity plot', str_fileName));
    t = 1:length(M);
    acell_bar{i}	= [ t' M'];
    saveas(h, sprintf('%s-average_spatial_intensity.jpg', str_fileName));
end

end