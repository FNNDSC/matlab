function [M_phenotype] = 			...
		splice(	M_phenotypeVar,		...
			V_phenotypeInVar)
%
% NAME
%
%  function [M_phenotype] = 			...
%  		splice(	M_phenotypeVar,		...
%  			V_phenotypeInVar)
%
% ARGS
%	INPUTS			TYPE		EXPLANATION
%	M_phenotypeVar		matrix		The phenotype that is subject
%							to GA processing and
%							variation. Each row
%							represents the variable
%							phenotype of a single
%							individual in the total
%							population.
%	V_phenotypeInVar	row vector	A phenotype mask. The length
%							of the vector is the
%							length of the final 
%							phenotype. Non-zero
%							entries in the mask
%							represent invariant
%							"genes" that are not
%							subject to the GA
%							algorithm.
%
% 	OUTPUTS			TYPE		EXPLANATION
% 	M_phenotype		matrix		The real valued phenotype that
%							is to be evaluated. It
%							comprises the variable
%							and invariant phenotypes
%							interleaved according to
%							the mask.
%
% DESCRIPTION
%
%	This function splices an invariant phenotype mask into a population
%	of phenotypes.
%
%	The need for this function arose from experiments wherein certain
%	phenotypes in a gene expression were required to remain invariant. The
%	template is encoded in V_phenotypeInVar. Entries that are zero are
%	variable, non-zero entries are invariant. For example, a mask of
%
%		V_phenotypeInVar	= [ 0 0 0 10 0 0 10 ]
%
%	means that each "final" phenotype should have '10' where indicated
%	and variable values for each of the zeroes. Thus, the input 
%	M_phenotypeVar would be a matrix of size [populationSize 5]. This
%	method will create a new matrix of size [populationSize 7] with the
%	invariant columns of '10' spliced in.
%
% HISTORY
% 14 June 2005
% o Initial design and coding.
%

function error_exit(	str_action, str_msg, str_id)
    fprintf(1, '\tFATAL:\n');
    fprintf(1, '\tSorry, some error has occurred in "splice.m".\n');
    fprintf(1, '\tWhile %s,\n', str_action);
    fprintf(1, '\t%s\n', str_msg);
    error(str_id);
end

[rows cols]	= size(M_phenotypeVar);
maskIndx 	= find(V_phenotypeInVar > 0);
origIndx	= zeros(1, length(maskIndx));
M_phenotype	= zeros(rows, length(V_phenotypeInVar));
maskStart	= 1;
origStart	= 1;

if ~length(maskIndx)
    M_phenotype	= M_phenotypeVar;
    return;
end

if (length(maskIndx) + cols) ~= length(V_phenotypeInVar)
    error_exit( 'checking inputs', ...
		'cannot splice: incompatible lengths on inputs', '2');
end

for pos=1:length(maskIndx)
    origIndx(pos) = maskIndx(pos) - pos + 1;
end

% spliced parts
for splice = 1:length(maskIndx)
    M_phenotype(:,maskStart:maskIndx(splice)-1) = ...
	M_phenotypeVar(:,origStart:origIndx(splice)-1);
    M_phenotype(:,maskIndx(splice)) = V_phenotypeInVar(maskIndx(splice));
    maskStart 	= maskIndx(splice)+1;
    origStart	= origIndx(splice);
end

% remainder
M_phenotype(:,maskStart:length(V_phenotypeInVar)) = ...
	M_phenotypeVar(:,origStart:cols);

end