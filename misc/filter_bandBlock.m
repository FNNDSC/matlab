function [aM_filt] = filter_bandBlock(aM, 	af_lowerThreshold, ...
						af_upperThreshold, ...
						varargin)
%
% NAME
%
%  	function [av_filt] = filter_bandBlock(av, 	af_lowerThreshold, ...
%							af_upperThreshold ...
%							[, ab_hardLimit])
%
% ARGUMENTS
% INPUT
%	aM			matrix		Matrix to filter
%	af_lowerThreshold	float		Filter lower threshold
%	af_upperThreshold	float		Filter upper threshold
%
% OPTIONAL
%	ab_hardLimit		bool		if true, hardLimit upper values
%						to <af_upperThreshold> and
%						lower values to 
%						<af_lowerThreshold>.
%
% OUTPUTS
%	aM_filt			matrix		Filtered matrix
%
% DESCRIPTION
%
%	'filter_bankBlock' operates as a band block filter. Anything between
%	the <af_lowerThreshold> and <af_upperThreshold> is blocked. If the
%	optional <ab_hardLimit> is set, the passed values are set to
%	<ab_hardLimit>.
%
% PRECONDITIONS
%
%	o Non-zero sized input <aM>.
%
% POSTCONDITIONS
%
%	o <aM_filt> which is a band blocked filter on <aM> is returned.
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

b_hardLimit	= 0;

if length(varargin)
	b_hardLimit	= varargin{1};
end

aM_filt	= aM * 0.0;
for i=1:numel(aM)
    if aM(i) < af_lowerThreshold
	if b_hardLimit
	    aM_filt(i)	= af_lowerThreshold;
	else
	    aM_filt(i)	= aM(i);
	end
    end

    if aM(i) > af_upperThreshold
	if b_hardLimit
	    aM_filt(i)	= af_upperThreshold;
	else
	    aM_filt(i)	= aM(i);
	end
    end
end

end