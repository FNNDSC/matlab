function [X, fval, exitflag, output] = ...
			dijkstra_optimiseToPath(X0, str_labelFileName)
%
% NAME
%
%	function [X, fval, exitflag, output] = ...
%			dijkstra_optimiseToPath(X0, str_labelFileName)
%
%
% ARGUMENTS
%
%	str_labelFileName	in (string)	the label filename containing
%						a reference path to optimise
%						against.
%	X0			in (vector)	initial "guess" vector
%
%	X			out (vector)	the vector weights that
%						optimise the given label
%	fval			out (scalar)	the function value at X
%	exitflag		out (int)	identifier describing the
%						reason the algorithm terminated
%	output			out (struct)	information about the
%						optimisation
% DESCRIPTION
%
%	'dijkstra_optimiseToPath' optimises a set of weights described in X
%	to a reference path described by str_labelFileName. It is essentially
%	a "meta" script that calls several nested functions to perform the
%	actual optimisation.
%
% PRECONDITIONS
%	
%	o 'nse' environment
%	o Ready-to-run 'dijkstra_p1' environment - including at the very least
%	  an 'options.txt' file for the back-end engine.
%	o A mkfifo 'sys_msg.log'.
%
% POSTCONDITIONS
%	
%	o The return parameters denote the solution to the optimisation problem.
%
% EXTERNAL DEPENDENCIES
%
%	o 'dijkstra_p1'
%	The dijkstra FreeSurfer-aware path search program.
%
%	o 'dijk_dscript.py'
%	The "main" Python script for driving 'dijkstra_p1'.
%
%	o 'SSocket_client' shell executable used by 'dijk_dscript.py' for
%	for communicating with the engine.
%
% HISTORY
%
% 23 March 2005
% o Initial design and coding.
%

	function error_exit(	str_action, str_msg, str_ret)
		fprintf(1, '\tFATAL:\n');
		fprintf(1, '\tSorry, some error has occurred.\n');
		fprintf(1, '\tWhile %s,\n', str_action);
		fprintf(1, '\t%s\n', str_msg);
		error(str_ret);
	end

	function [dstr]	= WGHT_set(str_weight, f_val)
	    dstr = sprintf('WGHT %s set %f', str_weight, f_val);
	end

	function [f] = dobjfunc(X)
	% NAME
	%
	%	function [f] = dobjfunc(X)
	%
	% ARGUMENTS
	%
	%	X		in (vector)		a vector of weights
	%	f		out (scalar)		the resultant from the 
	%						input X
	%
	% DESCRIPTION
	%
	%	'dobjfunc' is an unconstrained linear objective function used
	% 	in the dijkstra optimization process. In its simplest sense, 
	% 	this function is a MatLAB intermediary between a weight vector,
	% 	X, and a fitness evaluation, f.
	%
	%	Essentially, this function sets the weight values for a path
	%	search such that the found path is as close as possible to a
	%	passed reference label (passed to the main entry point).
	%
	%	The goal of this optimization is to minimize the difference 
	%	between the source reference and the weight-based calculation, 
	%	thus finding the optimal weight vector.
	%
	% PRECONDITIONS
	%	
	% 	o none
	%
	% POSTCONDITIONS
	%
	%	o the objective value 'f'.
	%
	% HISTORY
	% 22 March 2005
	% o Initial conceptualisation.
	%
	%

	    str_dshFileName	= '/tmp/dobjfunc.dsh';
	    fid_dsh		= fopen(str_dshFileName, 'w');

	    f = 0.0;

	    wghtCell	= {['wd'] ['wc'] ['wh'] ['wdc'] ['wdh'] ['wch'] ...
				['wdch'] ['wdir']};

	    str_X = num2str(X);
	    fprintf(1, 'For weight vector = %s\n', str_X);
	    fprintf(1, 'Creating dsh script...');
	    for w = 1:length(wghtCell) 
	        dstr = WGHT_set(wghtCell{w}, X(w));
		fprintf(fid_dsh, '%s\n', dstr);
	    end
	    fprintf(fid_dsh, 'RUN');
	    fprintf(1, '\t\t\t[ ok ]\n');

	    fprintf(1, 'Determining path...');
	    str_dsh = sprintf('dijk_dscript.py -s %s -q 2>/dev/null', ...
				 str_dshFileName);
	    [ret str_console] = unix(str_dsh);
	    if ret
	        fprintf(1, '\t\t\t[ failure ]\n');
		fprintf(1, '%s', str_console)
		error_exit( 	'starting back-end dijkstra engine', ...
				'some error was returned - see above.', ...
				'1');
	    end
	    fprintf(1, '\t\t\t[ ok ]\n');

	    fprintf(1, 'Finding correlation...');
	    str_correlate = sprintf('correlation_determineToRef.bash -s %s -t %s', ...
					str_labelFileName, 'dijk.label');
	    [ret str_console] = unix(str_correlate);
	    f = str2num(str_console);
	    f = 1 - f/100;
	    fprintf(1, '\t\t\t[ %f ]\n', f); 

	end % dobjfunc

    if length(X0) ~= 8
	error_exit( 'checking input X0 vector', ...
		    'this must be an 8-element vector', ...
		    1);
    end    
%    fval = dobjfunc(X0);
    options = optimset('LargeScale', 'off');
    [X, fval, exitflag, output]	= ...
	fminunc(@dobjfunc, X0, options);    

    fprintf(1, 'Fitness = %f\n', fval);
    fprintf(1, 'Normal termination.\n\n');

end % dijkstra_optimiseToPath