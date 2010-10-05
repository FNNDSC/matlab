function [av_curv, ab_singularity] = k1k2_createCurv(varargin)
%
% NAME
%
%  	function [av_curv, ab_singularity] = k1k2_createCurv(
%  						[astr_hemi='lh',
%						astr_outFileName])
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%	astr_hemi		string		hemisphere prefix to process
%	astr_outFileName	string		name of newly created output
%						curvature file
%
% OUTPUTS
%	av_curv			vector		curvature vector
%	ab_singularity		bool		1: singularities found
%
% DESCRIPTION
%
%	'k1k2_createCurv' reads in the principle curvature files for
%	a given hemisphere and applies an internal function of k1 and
%	k2 to each vertex. The resultant curvature is saved to 
%  	<astr_outFileName>.
%
% PRECONDITIONS
%
% 	o <astr_hemi>.smoothwm.{K1,K2} must exist.
%
% POSTCONDITIONS
%
%	o Some function of k1 and k2 is applied to each vertex
%	  of the input curvature vector. This resultant is saved
%	  to <astr_outFileName>.
%	o <astr_outFileName> defaults to 
%		('%s.smoothwm.fK1K2.crv', astr_hemi)
%	  
%
% SEE ALSO
%
% HISTORY
% 22 September 2006
% o Initial design and coding.
%
% 30 November 2006
% o ab_singularity
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

	function [F] = f(K1, K2)
	    singularity	= find(K1.^2 == K2.^2);
	    if length(singularity)
		fprintf(1, '\n\tSingularity points: %d', singularity);
		ab_singularity	= 1;
	    end
	    F = zeros(length(K1), 1);
%  	    F = K1.*K2;
%  	    F = (K1+K2).* 0.5;
%  	    F = K1;
%  	    F = K2;
%  	    F = abs((K1 .* K2));
%  	    F = abs((K1 .* K2)) ./ (K1  - K2).^2;
%	    F = (K1 .* K2) ./ (K1  - K2).^2;
	    F = (K1  - K2).^2;
%	    F = atan((K2+K1)./(K2-K1)).* (2/pi);
%   	    F = sqrt((K1.^2 + K2.^2)./2);
	end

%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 

ab_singularity	= 0;
str_hemi	= 'lh';
str_outFileName	= sprintf('%s.smoothwm.fK1K2', str_hemi);

if length(varargin)
	str_hemi	= varargin{1};
	str_outFileName	= sprintf('%s.smoothwm.fK1K2', str_hemi);
	if length(varargin) >= 2
		str_fname 	= varargin{2};
		str_outFileName = sprintf('%s', str_fname);
	end
end

str_K1			= sprintf('%s.smoothwm.K1', str_hemi);
str_K2			= sprintf('%s.smoothwm.K2', str_hemi);
[crv_K1, fnum_K1] = read_curv(str_K1);
[crv_K2, fnum_K2] = read_curv(str_K2);

%% Might need some error checking on size(K1, K2)

av_curv		= f(crv_K1, crv_K2);
write_curv(str_outFileName, av_curv, fnum_K1);

end