function [aM] = binomialInd_2find(ai)
% NAME
%
%  function [aM] = binomialInd_2find(ai)
%
% ARGUMENTS
% inputs
%	ai			int		size of sample
%
% optional
%
% outputs
%	aM			matrix		a 2D matrix - each
%						row contains the 
%						coefficient indices
%						for the 2D expansion.
%
% DESCRIPTION
%
%	'binomial_2find' returns the actual coefficient indices
%	for a 2D expansion, i.e. binomial(ai, 2).
%
% PRECONDITIONS
%
%	o <ai> should be an integer.
%	o depends on 'binomial.m'
%
% POSTCONDITIONS
%
%	o All possible expansions are returned in the <aM> matrix.
%	o Indices are returned counting from 1 (not 0).
%
% SEE ALSO
%
%	o 'binomial.m'
%
% HISTORY
%
% 21 September 2006
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

c	= binomial(ai, 2);
aM	= zeros(c, 2);
k	= 1;

for i=1:ai-1
    for j=i+1:ai
	if i~=j
	    aM(k, 1)	= i;
	    aM(k, 2)	= j;
	    k = k + 1;
	end
    end
end

end