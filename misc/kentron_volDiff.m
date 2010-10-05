function [] = kentron_volDiff(astr_fileNameVol1, astr_fileNameVol2, varargin)
% NAME
%
%  function [] = kentron_volDiff(	astr_fileNameVol1,
%					astr_fileNameVol2
%  				[, 	a_slabDir=<direction>,
%					a_inPlaneDir=<direction>])
%
%
% ARGUMENTS
% inputs
%	astr_fileNameVol1	string		name of volume 1
%	astr_fileNameVol2	string		name of volume 2
%
% optional
%	a_slabDir		int		plane direction to analyze:
%						1 - row
%						2 - col
%						3 - slice
%	a_inPlaneDir		int		in-plane direction to analyze:
%						1 - rowDir (i.e. across rows
%							or "up/down")
%						2 - colDir (i.e. across cols
%							or "left/right")
%
% outputs
%
% DESCRIPTION
%
%	'kentron_volDiff' simply finds the absolute difference between its
%	two input volumes. Also reported is the absolute difference in
%	intensity analysis.
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
% 10 September 2006
% o Initial design and coding.
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

slabDir		= 3; 		% slice direction
inPlaneDir	= 1;		% row direction

if length(varargin)
	slabDir	= varargin{1};
	if length(varargin) == 2
	    inPlaneDir = varargin{2};
	end
end

% First perform an intensity analysis on the inputs
cell_strName{1}		= astr_fileNameVol1;
cell_strName{2}		= astr_fileNameVol2;
cell_strName{3}		= './f_diff-tmp.mgh';

[V_kentron1, M_vox2ras, v_mrParams]	= load_mgh2(astr_fileNameVol1);
[V_kentron2, M_vox2ras, v_mrParams]	= load_mgh2(astr_fileNameVol2);

V_diff			= abs(V_kentron1 - V_kentron2);
save_mgh(V_diff, cell_strName{3}, M_vox2ras, v_mrParams);

for i = 1:3
    str_fileName	= sprintf('%s', cell_strName{i});
    [M_IA, M_image]	= kentron_volAn(str_fileName, slabDir, inPlaneDir);
    f_mean		= mean(mean(M_IA));
    f_std		= std(std(M_IA));
    fprintf(1, '%20s: intenisty analysis - mean: %f, std: %f\n', 	...
		str_fileName, f_mean, f_std);
    if i == 3
	colormap('default');
    	figure(i*10) ; mesh(M_IA); 	title(sprintf('Diff: %s %s', 	...
						cell_strName{1}, 	...
						cell_strName{2}));
	colormap('gray');
	figure(i*10+1); imshow(M_image, [0 255]); title(sprintf('Diff: %s %s', 	...
						cell_strName{1}, 	...
						cell_strName{2}));
	figure(i*10+2) ; hist(M_image);	title(sprintf('Hist - Diff: %s %s', ...
						cell_strName{1}, 	...
						cell_strName{2})); 
    end
end

end