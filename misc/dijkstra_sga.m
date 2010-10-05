	function [V_obj, M_phenotypeOpt] = dijkstra_sga(	...
					ga_params, 		...
					M_fieldD, 		...
					M_chromosomes,		...
					str_labelFile,		...
					varargin)

% NAME
%
%	function [V_obj, M_phenotypeOpt] = dijkstra_sga(	...
%					ga_params, 		...
%  					ga_params, 		...
%  					M_fieldD, 		...
%  					M_chromosomes,		...
%  					str_labelFile,		...
%  					varargin)
%
% ARGUMENTS
%
%	INPUTS			TYPE		DESC
%	ga_params		struct		Operational parameters for the
%							genetic algorithm
%	M_fieldD		matrix		Problem field description.
%	M_chromosomes		matrix		Total chromosome space for 
%							entire population.
%	str_labelFileName	string		Filename containing the path
%							or region to optimise
%							toward.
%	V_phenotypeMask		row vector	(OPTIONAL)
%						If specified, represents a 
%							phenotype template. 
%							Zeroes are variant, 
%							and decoded from the
%							GA chromosome, while
%							non-zeros are fixed and
%							passed directly into
%							objective phenotype. 
%
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
% DESCRIPTION
%
%	'dijkstra_sga' is a very simple re-hack of the single population
%	genetic algorithm example bundled with the Genetic Algorithm
%	Toolbox.
%
%	Operational parameters are passed in the input ga_param struct,
%	and a final objective function value is returned.
%
%	This function also calls a dijkstra_p1 stream aware objective
%	function.
%
% PRECONDITIONS
%	
%	o This function is dependent upon the Genetic Algorithm Toolbox.
%	o 'nse' environment
%	o Ready-to-run 'dijkstra_p1' environment - including at the very least
%	  an 'options.txt' file for the back-end engine.
%
% POSTCONDITIONS
%	
%	o The optimised generation-based objective and weight vector is 
%	  returned.
%
% HISTORY
%
% 01 April 2005
% o Initial design and coding.
%
% 14 April 2005
% o Testing with new 'dsh' intermediary.
%
% 14 June 2005
% o Added chromosome mask vector.
%

V_phenotypeMask		= [];
if length(varargin)
    V_phenotypeMask	= varargin{1};
end

maskIndx	= find(V_phenotypeMask > 0);

% Reset counters
    Best 		= NaN*ones(ga_params.generations+1, 1);
    gen 		= 0;

% Evaluate initial population
    fprintf(1, 'Distributing initial population (generation 0)...\n');
    M_phenotypeRaw	= bs2rv(M_chromosomes, M_fieldD);
    %V_phenotypeMask
    if length(maskIndx)
	M_phenotype	= splice(M_phenotypeRaw, V_phenotypeMask);
    else
	M_phenotype	= M_phenotypeRaw;
    end
    [rows cols]		= size(M_phenotype);
    M_phenotypeOpt	= NaN*ones(ga_params.generations+1, cols);	
    
    ObjV 	= ga_dobjfunc(M_phenotype, str_labelFile);

% Track best intial individual and display convergence
    Best(1) 			= min(ObjV);
    phenoIndex			= find(ObjV == min(ObjV));
    M_phenotypeOpt(1,:)		= M_phenotype(phenoIndex(1), :);
    str_ObjV			= sprintf('%f ', ObjV');
    fprintf(1, 'Objective Vector:\t%s\n', str_ObjV);
    fprintf(1, 'Best individual:\t%f\n', Best(gen+1));
    str_phenoBest = sprintf('%f ', M_phenotypeOpt(1, :));
    fprintf(1, 'Best Phenotype:\t\t%s\n', str_phenoBest);

%   plot(log10(Best),'ro');xlabel('generation'); ylabel('log10(f(x))');
%   text(0.5,0.95,['Best = ', num2str(Best(gen+1))],'Units','normalized');   
%   drawnow;        


% Generational loop
    while gen < ga_params.generations,
        % Increment generational counter
       	gen 			= gen+1;
	fprintf(1, '\nGeneration:\t\t%d\n', gen);

        % Assign fitness-value to entire population
       	FitnV = ranking(ObjV);

        % Select individuals for breeding
       	SelCh = select('sus', M_chromosomes, FitnV, ga_params.generationGap);

        % Recombine selected individuals (crossover)
       	SelCh = recombin('xovsp',SelCh,0.7);

        % Perform mutation on offspring
       	SelCh = mut(SelCh);

        % Evaluate offspring, call objective function
        %   ObjVSel = objfun1(bs2rv(SelCh, M_fieldD));
	M_phenotypeRaw	= bs2rv(SelCh, M_fieldD);
    	if length(maskIndx)
	    M_phenotype	= splice(M_phenotypeRaw, V_phenotypeMask);
    	else
	    M_phenotype	= M_phenotypeRaw;
	end	

       	ObjVSel 	= ga_dobjfunc(M_phenotype, str_labelFile);
    	str_ObjVSel	= sprintf('%f ', ObjVSel');
    	fprintf(1, 'Objective Vector:\t%s\n', str_ObjVSel);

        % Reinsert offspring into current population
       	[M_chromosomes ObjV]=reins( M_chromosomes, SelCh, 1, 1, ObjV, ObjVSel);

        % Update display and record current best individual
       	Best(gen+1) 		= min(ObjV);
    	phenoIndex		= find(ObjV == Best(gen+1));
    	M_phenotypeOpt(gen+1,:)	= M_phenotype(phenoIndex(1), :);
	fprintf(1, 'Best individual:\t%f\n', Best(gen+1));
	str_phenoBest 		= sprintf('%f ', M_phenotypeOpt(gen+1,:));
	fprintf(1, 'Best Phenotype:\t\t%s\n', str_phenoBest);

	%plot(log10(Best),'ro'); xlabel('generation'); ylabel('log10(f(x))');
	%text(0.5,0.95,['Best = ', num2str(Best(gen+1))],'Units','normalized');
	%drawnow;
    end 
% End of GA

V_obj	= Best;