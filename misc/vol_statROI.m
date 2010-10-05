function [aV, af_meanMask, af_stdMask] = vol_statROI(aV_input, varargin)
%
% NAME
%
%    function [aV, af_meanMask, af_stdMask] 	= vol_statROI(aV_input 
%                               [, af_stdOffset 	= -1
%                               [, aV_mask      	= aV_input
%				[, aV_inputIntensity	= aV_input]]])
%
%
% ARGUMENTS
%    INPUTS
%    aV_input		volume			data space to analyze for ROI
%
%    OPTIONAL
%    af_stdOffset       float scalar            standard deviation offset
%                                               to guide ROI selection
%    aV_mask            volume                  mask volume that contains
%                                               volume region to analyze
%    av_inputIntensity	volume			if specified, calculate 
%    						intensity stats on this
%    						volume instead of using
%    						<aV_input>    
%    
%    OUTPUTS
%    aV			volume			volume with ROI intensities
%                                               filtered
%    af_meanMask	float scalar		mean intensity across the mask
%    af_stdMask		float scalar		std intensity across the mask
%
% DESCRIPTION
%
%       'vol_statROI' selects regions of interest in an intensity
%       volume based on a simple statistical thresholding filter. The
%       selection is driven by the <af_stdOffset>, which implies a
%       multiple of the intensity standard deviation. All intensities that
%       are either less than (if a negative <af_stdOffset>) or higher than
%       (if a positive <af_stdOffset>) are selected.
%
%	If an optional <aV_mask> is passed, then only values in the
%	<aV_input> that correspond to non-zero intensities in the mask
%	are processed.
%
% PRECONDITIONS
%
%	o <aV_input> is a volume, i.e. 3 dimensional data structure.
%
% POSTCONDITIONS
%
%	o <aV> contains only the voxels that were thresholded by this
%         filter.
%       o The mean and std intensity across the mask volume is also
%         returned. These are typically used in an n-phase converging
%         loop, where filtered regions in the original volume are 
%         set to the mean value, ROIs extracted, repeat until
%         convergence.      
%
% HISTORY
% 12 December 2008
% o Initial design and coding.
%
% 31 March 2009
% o Expanded return values to include mean and std of mask.
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

str_scriptName  = 'vol_statROI';

f_stdOffset             = -1;
v_sizeInput		= size(aV_input);
V_maskAll               = ones(v_sizeInput);
V_mask			= ones(v_sizeInput);
aVmasked                = zeros(v_sizeInput);
aV			= aV_input;
V_inputIntensity	= aV_input;

if length(varargin) >= 1; f_stdOffset   	= varargin{1}; end
if length(varargin) >= 2; V_mask        	= varargin{2}; end
if length(varargin) >= 3; V_inputIntensity	= varargin{3}; end

v_sizeMask              = size(V_mask);
if v_sizeMask ~= v_sizeInput
    error_exit('checking volumes', 'mask and input volumes mismatch.', '1');
end
if length(v_sizeInput) ~= 3
    error_exit( 'examining input data',                         ...
                'data does not seem to be a volume',            ...
                '1');
end

v_mask          = find(V_mask > 0);
aVmasked(v_mask)= V_inputIntensity(v_mask);
v_inputMask     = V_inputIntensity(v_mask);
v_inputAll      = vol_vectorize(V_inputIntensity);

f_maxMask       = max(v_inputMask);
f_minMask       = min(v_inputMask);
af_meanMask     = mean(v_inputMask);
af_stdMask      = std(v_inputMask);

f_maxAll        = max(v_inputAll);
f_minAll        = min(v_inputAll);
f_meanAll       = mean(v_inputAll);
f_stdAll        = std(v_inputAll);

if size(v_inputMask) == size(v_inputAll)
  fprintf(1, '\tMask volume encompasses entire input of %d elements.\n',  ...
              prod(size(v_inputMask)));
else
  fprintf(1, '\tMask volume encompasses input subset with %d elements.\n',  ...
              prod(size(v_inputMask)));
end

cprintfn('max  (masked)', f_maxMask, 40, 20);
cprintfn('min  (masked)', f_minMask, 40, 20);
cprintfn('mean (masked)', af_meanMask, 40, 20);
cprintfn('std  (masked)', af_stdMask, 40, 20);
fprintf('\t\tWhole volume contains %d elements.\n', prod(size(v_inputAll)));
cprintfn('max   (whole)', f_maxAll, 40, 20);
cprintfn('min   (whole)', f_minAll, 40, 20);
cprintfn('mean  (whole)', f_meanAll, 40, 20);
cprintfn('std   (whole)', f_stdAll, 40, 20);

if f_stdOffset < 0; 
  aV = vol_filter(aV_input,                                             ...
                  f_minMask, af_meanMask+f_stdOffset*af_stdMask,          ...
                  0.0, aVmasked);
else
  aV = vol_filter(aV_input,                                             ...
                  af_meanMask+f_stdOffset*af_stdMask, f_maxMask,          ...
                  0.0, aVmasked);
end

end