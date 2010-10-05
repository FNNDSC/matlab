function [aM_intensityAnalysis, aV_frame] = 		...
			kentron_volAn(	astr_targetName,	...
					varargin)
% NAME
%
%  function [aM_intensityAnalysis, aV_frame] = 		...
%  			 kentron_volAn(	astr_targetName,	...
%					[, a_slabDir=<direction>,
%					   a_inPlaneDir=<direction>)
%
%
% ARGUMENTS
% inputs
%	astr_targetName		string		name of the volume to analyze
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
%	aM_intensityAnalysis	matrix		output matrix containing 
%						summary information of the
%						input volume spatial intensity
%						distribution. This is a matrix
%						that can be viewed with the
%						mesh() function.
%	aV_frame		volume		the target data in a frame
%						structured volume.
%
% DESCRIPTION
%
%	'kentron_volAn' performs a 3D spatial analysis on the intensity
%	values in a volume. The <a_slabDir> specifies which plane direction
%	to consider. For each slice in the <a_slabDir> plane, each column 
%	(or row, depending on <a_inPlaneDir>) is averaged. The resultant 
%	vector is stored, and used to construct a matrix wherein each row 
%	corresponds to each slice analysis (aM_intensityAnalysis).
%
%	The resultant analysis (aM_intensityAnalysis) matrix can be visualised
%	as a 3D mesh to illustrate the spatial intensity distribution across
%	the volume.
%
%	<aV_frame> returns the scanned volume as a 4D frame. Specific "frames"
%	can be extracted and displayed downstream from this function.
%
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
% 06 August 2006
% o Initial design and coding.
%
% 05 October 2006
% o Multi-frame volume returned.
%
% 24 January 2007
% o Swapped the 'slabDir' case logic
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

	function [aM_slab] = slab_get(aV, a_slabDir, a_slabNum )
	    switch a_slabDir
		case 1
		    aM_slab = squeeze(aV(a_slabNum, :, :));
		    aM_slab = aM_slab';
		case 2
		    aM_slab = squeeze(aV(:, a_slabNum, :));
		case 3
		    aM_slab = squeeze(aV(:, :, a_slabNum));	
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

%  [V_kentron, M_vox2ras, v_mrParams]	= load_mgh2(astr_targetName);
S_mri				 	= MRIread(astr_targetName);
V_kentron				= S_mri.vol;
v_dim					= size(V_kentron);
slabDir;
switch slabDir
    case 1
	if inPlaneDir == 1
	    inPlaneSize	= v_dim(3);
	else
	    inPlaneSize	= v_dim(2);
	end
    case 2
	if inPlaneDir == 1
	    inPlaneSize	= v_dim(1);
	else
	    inPlaneSize	= v_dim(3);
	end
    case 3
	if inPlaneDir == 1
	    inPlaneSize	= v_dim(2);
	else
	    inPlaneSize	= v_dim(1);
	end
end

aM_intensityAnalysis	= zeros(v_dim(slabDir), inPlaneSize);
size(aM_intensityAnalysis);
numSlabs 	= v_dim(slabDir);

for slab = 1:numSlabs
    M_slab	= slab_get(V_kentron, slabDir, slab);
    if slab == 1
	frameSize	= size(M_slab);
	aV_frame	= zeros(frameSize(1), frameSize(2), 1, numSlabs);
    end
    aV_frame(:, :, 1, slab) = M_slab;
    v_mean	= mean(M_slab, inPlaneDir);
    if inPlaneDir == 2 
	v_mean	= v_mean';
    end
    size(v_mean);
    aM_intensityAnalysis(slab,:)	= v_mean;
end

end
