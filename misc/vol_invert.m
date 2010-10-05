function [aV] = vol_invert(aV_input, varargin)
%
% NAME
%
%    function [aV] = vol_invert(aV_input [, aV_maskVol])
%
%
% ARGUMENTS
%    INPUTS
%    aV_input		volume			data space to "invert"
%    aV_maskVol		volume (optional)	if specified, use non-zero
%    						entries as mask for inversion
%
%    OUTPUTS
%    aV			volume			volume with intensities
%    						inverted
%
% DESCRIPTION
%
%	'vol_invert' "inverts" the intensity values of its input volume, 
%	creating a "negative" image.
%	
%	If an optional <aV_maskVol> is passed, then only values in the
%	<aV_input> that correspond to non-zero intensities in the mask
%	are processed.
%
% PRECONDITIONS
%
%	o aV_input is a volume, i.e. 3 dimensional data structure.
%
% POSTCONDITIONS
%
%	o A logical "negative" (i.e. inverted intensity) volume is returned.
%
%
% HISTORY
% 08 December 2008
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

v_sizeInput		= size(aV_input);
V_mask			= ones(v_sizeInput);
aV			= zeros(v_sizeInput);

if length(varargin) >= 1, V_mask	= varargin{1};  end

v_sizeMask		= size(V_mask);
if v_sizeMask ~= v_sizeInput
    error_exit('checking volumes', 'mask and input volumes mismatch.', '1');
end

v_mask          = find(V_mask > 0);
aV(v_mask)      = aV_input(v_mask);

f_max	= max(max(max(aV_input)));
f_min	= min(min(min(aV_input)));
f_range	= f_max - f_min;

for i=1:v_sizeInput(1)
    for j=1:v_sizeInput(2)
	for k=1:v_sizeInput(3)
	    if V_mask(i, j, k)
		f_delta		= aV_input(i, j, k) - f_min;
		f_inv		= f_max - f_delta;
		aV(i, j, k)	= f_inv;
	    end
	end
    end
end

end