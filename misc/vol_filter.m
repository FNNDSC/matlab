function [aV] = vol_filter(aV_input, af_lower, af_upper, varargin)
%
% NAME
%
%    function [aV] = vol_filter(aV_input, af_lower, af_upper
%                               [, af_noPasVal, aV_mask])
%
%
% ARGUMENTS
%    INPUTS
%    aV_input		volume			data space to filter
%    af_lower           float                   lower bound on filter
%    af_upper           float                   upper bound on filter
%
%    OPTIONAL
%    af_noPassVal       float                   values that are filtered out
%                                               are set to af_noPassVal
%    aV_mask            volume                  mask volume
%
%    OUTPUTS
%    aV			volume                  filtered volume
%    
% DESCRIPTION
%
%	'vol_filter' is a simple bandpass filter such that input values X where
%       
%                               af_lower <= X <= af_upper 
%                               
%       are filtered through. Values not filtered are set to af_noPassVal
%       (default 0.0).
%       
%       If the optional aV_mask is also specified, then only values in the
%       input volume that correspond to non-zero values in this mask are
%       processed.
%       
% PRECONDITIONS
%
%	o aV_input is a volume, i.e. 3 dimensional data structure.
%       o aV_mask, if passed, must have same size as aV_input      
%
% POSTCONDITIONS
%
%	o An appropriately filtered volume is returned.
%
%
% HISTORY
% 11 December 2008
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
aVmasked                = zeros(v_sizeInput);
f_noPassVal             = 0.0;

if length(varargin) >= 1; f_noPassVal   = varargin{1}; end
if length(varargin) >= 2; V_mask        = varargin{2}; end

v_sizeMask		= size(V_mask);
if v_sizeMask ~= v_sizeInput
    error_exit('checking volumes', 'mask and input volumes mismatch.', '1');
end

v_mask          = find(V_mask > 0);
aVmasked(v_mask)= aV_input(v_mask);

v_hits          = find(aVmasked >= af_lower & aVmasked <= af_upper);
aV(v_hits)      = aVmasked(v_hits);

%  for i=1:v_sizeInput(1)
%      for j=1:v_sizeInput(2)
%  	for k=1:v_sizeInput(3)
%  	    if V_mask(i, j, k)
%                switch str_filter
%                  case 'lp'
%                    if aV_input(i, j, k) <= af_threshold
%                      aV(i, j, k) = aV_input(i, j, k);
%                    else
%                      aV(i, j, k) = f_noPassVal;
%                    end
%                  case 'hp'
%                    if aV_input(i, j, k) >= af_threshold
%                      aV(i, j, k) = aV_input(i, j, k);
%                    else
%                      aV(i, j, k) = f_noPassVal;
%                    end
%                end
%  	    end
%  	end
%      end
%  end

end