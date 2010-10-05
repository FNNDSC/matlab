function [av_sa2v] = sa2v(av_SA, av_Vol)
%
% NAME
%
%  	function [av_sa2v] = sa2v(av_SA, av_Vol)
%
% ARGUMENTS
% INPUT
%	av_SA			vector		Surface area measures
%	av_Vol			vector		Volume measures
%
% OPTIONAL
%
% OUTPUTS
%	av_sa2v			vector		ratio of SA to Vol^(2/3)
%
% DESCRIPTION
%
%	'sa2v' returns the result of the ratio of the surface area vector
%	to the 2/3 power of the volume vector. This is useful for comparing
%	a squared power (the SA) to a cubed power (the volume).
%
% PRECONDITIONS
%
%	o length(av_SA) = length(av_Vol)
%
% POSTCONDITIONS
%
%	o 2/3rd power ratio is returned.
%
% SEE ALSO
%
% HISTORY
% 13 October 2006
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

	function [Z] = F(K1, K2)
	    singularity	= find(K2 == 0);
	    if length(singularity)
		fprintf(1, '\n\tSingularity points: %d\t\t', singularity);
		error_exit(	'determining ratio', 		...
				'singularity points found', 	...
				'1')
	    end
	    K2 = K2 .^ (2/3);
	    Z = K1 ./ (K2);
	end


%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 

if length(av_SA) ~= length(av_Vol)
	error_exit(	'checking on inputs',		...
			'inputs are not same length',	...
			'1');
end

av_sa2v		= F(av_SA, av_Vol);

end