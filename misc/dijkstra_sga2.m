	function [objV]	= dijkstra_sga(	ga_params, 	...
					M_fieldD, 	...
					M_chromosomes,	...
					str_labelFile)


% sga
%
% This script implements the Simple Genetic Algorithm described
% in the examples section of the GA Toolbox manual.
%

% Author:     Andrew Chipperfield
% History:    23-Mar-94     file created
 

NIND = ga_params.populationSize;           % Number of individuals per subpopulations
MAXGEN = ga_params.generations;        % maximum Number of generations
GGAP = ga_params.generationGap;           % Generation gap, how many new individuals are created
NVAR = ga_params.numberChromosomes;           % Number of variables
PRECI = ga_params.bitPrecision;          % Precision of binary representation

% Build field descriptor
   FieldD = [rep([PRECI],[1, NVAR]); rep([-512;512],[1, NVAR]);...
              rep([1; 0; 1 ;1], [1, NVAR])];

   FieldD = M_fieldD;

% Initialise population
   Chrom = crtbp(NIND, NVAR*PRECI);
   Chrom = M_chromosomes;

% Reset counters
   Best = NaN*ones(MAXGEN,1);	% best in current population
   gen = 0;			% generational counter

% Evaluate initial population
   ObjV = objfun1(bs2rv(M_chromosomes, M_fieldD));

% Track best individual and display convergence
   Best(gen+1) = min(ObjV);
   plot(log10(Best),'ro');xlabel('generation'); ylabel('log10(f(x))');
   text(0.5,0.95,['Best = ', num2str(Best(gen+1))],'Units','normalized');   
   drawnow;        


% Generational loop
   while gen < MAXGEN,

    % Assign fitness-value to entire population
       FitnV = ranking(ObjV);

    % Select individuals for breeding
       SelCh = select('sus', M_chromosomes, FitnV, GGAP);

    % Recombine selected individuals (crossover)
       SelCh = recombin('xovsp',SelCh,0.7);

    % Perform mutation on offspring
       SelCh = mut(SelCh);

    % Evaluate offspring, call objective function
       ObjVSel = objfun1(bs2rv(SelCh,FieldD));

    % Reinsert offspring into current population
       [Chrom ObjV]=reins(Chrom,SelCh,1,1,ObjV,ObjVSel);

    % Increment generational counter
       gen = gen+1;

    % Update display and record current best individual
       Best(gen+1) = min(ObjV);
       plot(log10(Best),'ro'); xlabel('generation'); ylabel('log10(f(x))');
       text(0.5,0.95,['Best = ', num2str(Best(gen+1))],'Units','normalized');
       drawnow;
   end 
% End of GA
