function [aV] = vol_binarize(aV_input, varargin)
%
% NAME
%
%    function [aV] = vol_binarize(aV_input, [, af_binValue, af_false])
%
%
% ARGUMENTS
%    INPUTS
%    aV_input		volume			data space to binarize
%
%    OPTIONAL
%    af_binValue        float                   binary value (default = 1)
%    af_false           float                   'false' value (default = 0)
%
%    OUTPUTS
%    aV			volume                  binarized volume
%    
% DESCRIPTION
%
%	'vol_binarize' converts any non-false values in the input aV_input
%       to 1.0, returning them in aV.
%       
%       If an optional af_binValue is specified, the binary value is set
%       to this instead of 1.0. Similarly the value of af_false, if specified
%       defines the 'false' value in the input.
%       
% PRECONDITIONS
%
%	o aV_input is a volume, i.e. 3 dimensional data structure.
%
% POSTCONDITIONS
%
%	o An appropriately binarized volume is returned.
%
%
% HISTORY
% 22 March 2010
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

f_binValue      = 1.0;
f_false         = 0.0;
if length(varargin),    f_binValue      = varargin{1};  end;
if length(varargin) >= 2, f_false       = varargin{2};  end;

aV      = aV_input;
aV(find(aV ~= f_false))                 = f_binValue;

end