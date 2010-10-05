function [aM_filt] = filter_gaussianCurv(astr_Kfile, af_threshold, varargin)
%
% NAME
%
%  	function [aM_filt] = filter_gaussianCurv(astr_Kfile,	... 
%						af_threshold [, ...
%						ab_hardLimit,	...
%						astr_KfileOut])
%
% ARGUMENTS
% INPUT
%	astr_Kfile		string		FreeSurfer curv file to process
%	af_threshold		float		Filter threshold
%
% OPTIONAL
%	ab_hardLimit		bool		if true, hardLimit values above
%						<af_threshold> to
%						<ab_hardLimit>.
%	astr_KfileOut		string		output curvature file; defaults
%						to <astr_Kfile>.<af_threshold>
%
% OUTPUTS
%	aM_filt			matrix		Filtered matrix
%
% DESCRIPTION
%
%	'filter_gaussianCurv' process an input FreeSurfer curvature file
%	and filters out all values greater than <af_threshold>^2 -- these
%	are saved in turn to an output FreeSurfer curvature file.
%
%	If the optional <ab_hardLimit> is set, the passed values are set to
%	<ab_hardLimit>.
%
% PRECONDITIONS
%
%	o Valid FreeSurfer input curvature file, <astr_Kfile>.
%
% POSTCONDITIONS
%
%	o <aM_filt> which is a upper limited filter on <aM> is returned.
%	o A FreeSurfer curvature file, <astr_Kfile>.<af_threshold> is
%	  also saved to current directory.
%
% SEE ALSO
%
%	o filter_upperPass.m
%	o read_curv.m
%	o write_curv.m
%
% HISTORY
% 04 January 2008
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

    	function sys_print(astr)
        	vprintf(1, sprintf('%s %s', syslog_prefix(), astr));
    	end

	function vprintf(level, str_msg)
	    if verbosity >= level
		fprintf(1, str_msg);
	    end
	end

%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 

verbosity	= 1;
b_hardLimit	= 0;
str_outputFile	= sprintf('%s.%f', astr_Kfile, af_threshold);
if length(varargin)
	b_hardLimit	= varargin{1};
	if length(varargin) >= 2
		str_outputFile	= varargin{2};
	end
end

sys_print(sprintf('| reading curvature file %s...\n', astr_Kfile));
[aM, fnum]	= read_curv(astr_Kfile);
sys_print('| filtering...\n');
[aM_filt]	= filter_upperPass(aM, 1/(af_threshold^2), b_hardLimit, b_hardLimit);
sys_print(sprintf('| writing curvature file %s...\n', str_outputFile));
write_curv(str_outputFile, aM_filt, fnum);

end