function [aM_filt] = filter_bandPass(aM, 	af_lowerThreshold, ...
						af_upperThreshold, ...
						varargin)
%
% NAME
%
%  	function [aM_filt] = filter_bandPass(aM, 	af_lowerThreshold, ...
%							af_upperThreshold  ...
%                                                       [, ab_hardLimit])
%
% ARGUMENTS
% INPUT
%	aM			matrix		Matrix to filter
%	af_lowerThreshold	float		Filter lower threshold
%	af_upperThreshold	float		Filter upper threshold
%
% OPTIONAL
%
%       ab_hardLimit            bool            Apply hard limit
%
% OUTPUTS
%	aM_filt			matrix		Filtered matrix
%
% DESCRIPTION
%
%	'filter_bankPass' is a simple band-pass filter. Anything
%	between the lower and upper threshold (including) is passed
%	through. If <ab_hardLimit> is TRUE, then hardlimit values outside
%       this range to the closest threshold, otherwise, non-passed
%       values are set to 0.
%
% PRECONDITIONS
%
%	o Non-zero sized input <aM>.
%
% POSTCONDITIONS
%
%	o <aM_filt> which is a band pass filter on <aM> is returned.
%
% SEE ALSO
%
% HISTORY
% 20 November 2006
% o Initial design and coding.
%
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

b_hardLimit	= 0.0;

if length(varargin)
    b_hardLimit = varargin{1};
end

aM_filt	= aM * 0.0;
for i=1:numel(aM)
    if aM(i) >= af_lowerThreshold & aM(i) <= af_upperThreshold
	aM_filt(i)	= aM(i);	
    elseif b_hardLimit
	if aM(i) < af_lowerThreshold
	    aM(i)	= af_lowerThreshold;
	elseif aM(i) > af_upperThreshold
	    aM(i)	= af_upperThreshold;
	end
    end
end

end
