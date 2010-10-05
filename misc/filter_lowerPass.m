function [aM_filt] = filter_lowerPass(aM, af_threshold, varargin)
%
% NAME
%
%  	function [aM_filt] = filter_lowerPass(aM, af_threshold          ...
%                                            [, ab_hardLimit])
%
% ARGUMENTS
% INPUT
%	aM			matrix		Matrix to filter
%	af_threshold		float		Filter threshold
%
% OPTIONAL
%	ab_hardLimit		bool		if true, hardLimit values above
%						<af_threshold> to 
%                                               <af_threshold>.
%
% OUTPUTS
%	aM_filt			matrix		Filtered matrix
%
% DESCRIPTION
%
%	'filter_lowerPass' filters a lower bound on in its input matrix. Only
%	values less than or equal to <af_threshold> are let through. If
%	the optional <ab_hardLimit> is set, values above <af_threshold> are
%       set to <af_threshold> (otherwise they are simply set to 0).
%
% PRECONDITIONS
%
%	o Non-zero sized input <aM>.
%
% POSTCONDITIONS
%
%	o <aM_filt> which is a lower limited filter on <aM> is returned.
%
% SEE ALSO
%
% HISTORY
% 20 November 2006
% o Initial design and coding.
%
% 03 December 2009
% o Logic changes/fixes -- lower passed values are not changed.
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

aM_filt	= aM;
for i=1:numel(aM)
    if aM(i) >= af_threshold
        if b_hardLimit
            aM_filt(i)	= af_threshold;
        else
            aM_filt(i)  = 0.0;
        end
    else
        aM_filt(i)	= aM(i);
    end
end

end