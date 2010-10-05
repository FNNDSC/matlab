function [s_ga, M_fieldD, M_chromosomes] = 			...
		ga_struct(	populationSize, 	...
				generations, 		...
				generationGap, 		...
				numberChromosomes,	...
				bitPrecision,		...
				lowerBound,		...
				upperBound)

%
% NAME
%
%  	function [s_ga, FieldD, Chromosomes] = 			...
%  			ga_struct(	populationSize, 	...
%  					generations, 		...
%  					generationGap, 		...
%  					numberChromosomes,	...
%  					bitPrecision,		...
%  					lowerBound,		...
%  					upperBound)
%
% ARGUMENTS
%
%	INPUTS			TYPE		DESC
%  	populationSize		scalar int	Size of total population
%  	generations		scalar int	Max number of generations
%  	generationGap		scalar float	Child population size
%							fraction of parent
%							population size
%  	numberChromosomes	scalar int	Number of variables in the
%							genotype
%  	bitPrecision		scalar int	The bit precision for the
%							genotype
%	lowerBound		scalar float	Lower bound on variable range
%	upperBound		scalar float	upper bound on variable range
%
%	OUTPUTS
%	s_ga			struct		All the inputs combined into
%							a structure.
%	M_fieldD		matrix		The problem field descriptor.
%	M_chromosomes		matrix		A matrix of <populationSize> 
%							uniformly distributed 
%							random binary strings
%							of length 
%							<numberChromosomes> *
%							<bitPrecision>
% DESCRIPTION
%
%	's_ga' is a struct "constructor" in as much as it accepts a group
%	of input argments and packs them into a struct, which is returned
%	to the caller. The idea of this struct is to be used as an input
%	argument to genetic algorithm functions, condensing several 
%	arguments into one.
%
%	The struct field names are the same as the input variable names.
%
% PRECONDITIONS
%	
%	o This struct is used ultimately with the Genetic Algorithm Toolbox.
%
% POSTCONDITIONS
%	
%	o A populated struct is returned.
%
% HISTORY
%
% 01 April 2005
% o Initial design and coding.
%

c	= cell(1, 7);
c{1}	= populationSize;
c{2}	= generations;
c{3}	= generationGap;
c{4}	= numberChromosomes;
c{5}	= bitPrecision;
c{6}	= lowerBound;
c{7}	= upperBound;
s_ga = struct(	'populationSize', 	c{1},	...
		'generations',		c{2},	...
		'generationGap',	c{3},	...
		'numberChromosomes',	c{4},	...
		'bitPrecision',		c{5},	...
		'lowerBound',		c{6},	...
		'upperBound',		c{7});

% Build field descriptor
M_fieldD 	= [	rep([bitPrecision],[1, numberChromosomes]); ...
			rep([lowerBound; upperBound],[1, numberChromosomes]);...
              		rep([1; 0; 1 ;1], [1, numberChromosomes])];

% Initialise population
M_chromosomes 	= crtbp(populationSize, numberChromosomes*bitPrecision);


