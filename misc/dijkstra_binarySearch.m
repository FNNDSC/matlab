function [Xmin, fmin, Xall, errcount] = ...
		dijkstra_binarySearch(str_labelFileName, varargin)
% NAME
%
%	function [Xmin, fmin, Xall, errcount] = ...
%		dijkstra_binarySearch(str_labelFileName, ...
%				varargin)
%
%
% ARGUMENTS
%	INPUTS
%	str_labelFileName	string		FreeSurfer label file 
%							describing reference
%							(optimal) trajectory
%	verbosity		int (optional)	verbosity setting. If 0,
%							no output is echoed,
%							if 1, only final value
%							if >1, everything.
%	extLoop			int (optional)	a variable containing an
%							external loop counter -
%							useful for tracking
%							progress when performing
%							batch optimisations
%
%	OUTPUTS
%	Xmin			vector		The weight vector with the
%							minimum objective
%							value.
%	fmin			scalar		The objective value
%							corresponding to Xmin.
%	Xall			matrix		The entire objective weight space.
%	errcount		scalar		Number of errors captured in the 
%							objective evaluation.
%
% DESCRIPTION
%
%	'dijkstra_binarySearch' iterates over the dijkstra weight vector, 
%	assuming it to be a binary vector. For each possible combination
%	of ON|OFF weight values, the objective function value is captured.
%
%	The minimum value, as well as the minimising vector, are returned
%	to the calling process.
%
% PRECONDITIONS
%
%	o nse
%	
% 	o <str_labelFileName> must contain a valid FreeSurfer label format
%	  file.
%
% POSTCONDITIONS
%
%	o the minumum weight vector, Xmin, and objective value 'fmin'.
%
% HISTORY
% 19 April 2005
% o Initial conceptualisation.
%
% 08 August 2005
% o Extensions to facilitate embedding in a larger processing loop.
% 	- printing current str_labelFileName
%	- printing external loop counter
%
% 18 October 2005
% o Added <Xall> as a return value.
% 	- Contains the entire (sorted by fval) weight space. This is
%	  useful for tracking duplicate minima.
%
% 01 December 2005
% o Added call to dobjfunc in error exception loop - hopefully this
%   will fix the endless assignment exceptions that occur!
%
%
	function vprintf(level, str_msg)
	    if verbosity >= level
		fprintf(1, str_msg);
	    end
	end

binSearchSpace	= 255;
Xall		= zeros(binSearchSpace, 9);
Xmin 		= zeros(1, 8);
X		= zeros(1, 8);
fmin		= 100;
verbosity	= 0;
extLoop		= 0;
errcount	= 0;
b_assignError	= 0;

if length(varargin)
	verbosity	= varargin{1};
	if length(varargin) == 2
		extLoop   = varargin{2};
	end
end

vprintf(2, '\n');

for i=0:binSearchSpace
	str_i	= dec2bin(i, 8);
	for j=1:8
		if str_i(j) == '1'
			binval 	= 1;
		else
			binval	= 0;
		end
		X(j)	= binval;
	end
	f 			= dobjfunc(X, str_labelFileName);
	Xall(i+1, 1:8)		= X;
	% Occasionally the 'dobjfunc' returns an empty set, [] - most likely
	% as a result of a mis-timing or mis-synchronisation somewhere in the
	% backend communication chain. A first approach to handling this is
	% to pause for a few seconds, and then redo the evaluation.
	b_assignError		= 1;
	while b_assignError
 	    try
		Xall(i+1, 9)	= f;
		b_assignError	= 0;
	    catch
		vprintf(2, 'Error caught. Retrying assignment...\n');
		pause(5);
		errcount	= errcount + 1;
		b_assignError	= 1;	
		f		= dobjfunc(X, str_labelFileName);
	    end
	end
	str_labelBaseCMD	= sprintf('basename %s .label', str_labelFileName);
	[status str_labelBase]	= unix(str_labelBaseCMD);
	[str_labelName str_rem]	= strtok(str_labelBase, char(10)); 
	vprintf(2, ...
	    sprintf('(%s[%d])\t%d:\t%s\t%f\n', str_labelName, extLoop, i, str_i, f));
	if f < fmin
		fmin 		= f;
		Xmin		= X;
		str_Xmin	= str_i;
	end
end

vprintf(1, ...
	sprintf('\tminimum value of %f occurred at %s', fmin, str_Xmin));

end