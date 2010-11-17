function [aS_stats] = vol_stats(aV_input, varargin)
%
% NAME
%
%    function [aS_stats] = vol_stats(aV_input [, aV_maskVol])
%
%
% ARGUMENTS
%    INPUTS
%    aV_input		volume			data space to analyze
%    aV_maskVol		volume (optional)	if specified, process only
%                                                 entries in volume that
%                                                 correspond to non-zero
%                                                 entries in the mask.
%    OUTPUTS
%    aS_stats           struct                  Return struct, consisting of:
%       mf_mean            scalar                  mean
%       mf_std             scalar                  standard deviation
%       mf_min             scalar                  min value in volume
%       mf_max             scalar                  max value in volume
%       m_size             scalar                  number of elements processed
%
% DESCRIPTION
%
%	'vol_stats' returns some simple statistics for its passed volume
%       argument.
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
%	o various stats are returned
%
% HISTORY
% 15 September 2009
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

if length(varargin) >= 1, V_mask        = varargin{1};  end

v_sizeMask		= size(V_mask);
if v_sizeMask ~= v_sizeInput
    error_exit('checking volumes', 'mask and input volumes mismatch.', '1');
end

v_mask          = find(V_mask > 0);
aV(v_mask)      = aV_input(v_mask);

af_max	= max(aV(:));
af_min	= min(aV(:));
f_range	= af_max - af_min;

l       = 0;
v_input = zeros(1, numel(aV));
for i=1:numel(aV)
    if V_mask(i)
        l               = l + 1;
        v_input(l)      = aV(i);
    end
end

v_masked        = v_input(1:l);
af_mean         = mean(v_masked);
af_std          = std(v_masked);
a_size          = l;

% Return structure
aS_stats                = struct;
aS_stats.mf_mean        = af_mean;
aS_stats.mf_std         = af_std;
aS_stats.mf_min         = af_min;
aS_stats.mf_max         = af_max;
aS_stats.m_size         = a_size;

end