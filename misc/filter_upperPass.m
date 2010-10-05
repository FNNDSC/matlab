function [aM_filt] = filter_upperPass(aM, af_threshold, varargin)
%
% NAME
%
%  	function [aM_filt] = filter_upperPass(aM, af_threshold 		...
%					     [, ab_hardLimit,		...
%					        af_limitValue])
%
% ARGUMENTS
% INPUT
%	aM			matrix		Matrix to filter
%	af_threshold		float		Filter threshold
%
% OPTIONAL
%	ab_hardLimit		bool		if true, hardLimit values above
%						<af_threshold> to
%						<af_threshold>.
%	af_limitValue		float		if specified in conjunction 
%						with <ab_hardLimit>, set each
%						non-filtered value to 
%                                               <af_limitValue>.
%
% OUTPUTS
%	aM_filt			matrix		Filtered matrix
%
% DESCRIPTION
%
%	'filter_upperPass' filters an upper bound on in its input matrix. Only
%	values greater than or equal to <af_threshold> are let through. If
%	the optional <ab_hardLimit> is set, values that are not filtered are
%       set to <af_threshold>, else they are set to 0.
%
% PRECONDITIONS
%
%	o Non-zero sized input <aM>.
%
% POSTCONDITIONS
%
%	o <aM_filt> which is a upper limited filter on <aM> is returned.
%
% SEE ALSO
%
% HISTORY
% 20 November 2006
% o Initial design and coding.
%
%
% 04 January 2008
% o <af_limitValue> extensions.
%
% 30 March 2009
% o Fixed the threshold to lte (aM(i) <= af_threshold)
% 
% 03 December 2009
% o Changed the logic that hardlimiting only affects non-filtered elements.
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

b_limitValue	= 0;
b_hardLimit	= 0;
f_limitValue	= af_threshold;

if length(varargin)
	b_hardLimit	= varargin{1};
	if(length(varargin)>=2 && b_hardLimit)
	    b_limitValue	= 1;
	    f_limitValue	= varargin{2};
	end
end

aM_filt	= aM;
for i=1:numel(aM)
    if aM(i) <= af_threshold
        if b_hardLimit
            aM_filt(i)  = f_limitValue;
        else
            aM_filt(i)  = 0.0;
        end
    else
        aM_filt(i)	= aM(i);
    end
end

end