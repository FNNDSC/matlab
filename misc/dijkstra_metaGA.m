function [V_obj, M_phenotypeOpt] = dijkstra_metaGA(				...
				populationSize,		...
				generations,		...
				generationGap,		...
				numberChromosomes,	...
				bitPrecision,		...
				lowerBound,		...
				upperBound,		...
				str_labelFile,		...
				varargin)
%
% NAME
%
%  function [V_obj, M_phenotypeOpt] = dijkstra_metaGA(			...
%  				populationSize,		...
%  				generations,		...
%  				generationGap,		...
%  				numberChromosomes,	...
%  				bitPrecision,		...
%  				lowerBound,		...
%  				upperBound,		...
%  				str_labelFile,		...
%  				varargin)
%
% ARGS
%
%	INPUTS			TYPE		EXPLANATION
%	populationSize		int		Total number of individuals
%	generations		int		Total number of simulations
%	generationGap		float (<1)	Reproduction differential
%							between generations
%	numberChromosomes	int		Number of chromosomes (see also
%							V_phenotypeMask). This 
%							is the total number of
%							chromosomes, including 
%							those that might be
%							masked by 
%							V_phenotypeMask.
%	bitPrecision		int		Precision of each chromosome
%	lowerBound		float		Lower value for each chromosome
%							phenotype
%	upperBound		float		Upper value for each chromosome
%							phenotype
%	str_labelFile		string		FreeSurfer label file that 
%							serves as the reference
%							for optimisation
%	V_phenotypeMask		row vector	(OPTIONAL)
%							If specified, defines
%							a mask phenotype template.
%							Elements containing zero
%							are encoded by chromo-
%							somes, non zero 
%							elements remain "fixed"
%							in the phenotype.
%	OUTPUTS
%	V_obj			vector		Final object value vector. Each
%							element is the best 
%				 			objective value for a
%							given generation.
%	M_phenotypeOpt		matrix		A matrix of real valued chromo-
%							some values. Each row 
%							corresponds to the
%							best phenotype of 
%							that generation.
%
% DESC
%
%	This function serves as the main entry point to a family of functions
%	that together implement the path optimisation.
%
%	In the default case, no V_phenotypeMask need be specified. The entire
%	chromosomal range will be used. After such a default run, however,
%	chromosomes might be flagged as more important than others. Subsequent
%	runs can "freeze" a particular value for a chromosome but specifying 
%	the value if V_phenotypeMask. Non-zero entries in this mask are "removed"
%	from the gene pool, and passed invariant through to the objective 
%	function.
%
% HISTORY
% 14 June 2005
% o Initial design and coding.
%

if length(varargin)
    V_phenotypeMask	= varargin{1};
else
    V_phenotypeMask	= [];
end

maskIndx	= find(V_phenotypeMask > 0);
if length(maskIndx)
    numberChromosomes = numberChromosomes - length(maskIndx);
end

[s_ga, M_fieldD, M_chromosomes] = ga_struct(		...
				populationSize,		...
				generations,		...
				generationGap,		...
				numberChromosomes,	...
				bitPrecision,		...
				lowerBound,		...
				upperBound);

[V_obj, M_phenotypeOpt] 	= dijkstra_sga(		...
				s_ga,			...
				M_fieldD,		...
				M_chromosomes,		...
				str_labelFile,		...
				V_phenotypeMask);

