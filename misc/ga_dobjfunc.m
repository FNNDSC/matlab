function [F] = ga_dobjfunc(M_X, str_labelFileName, varargin)
% NAME
%
%	function [F] = ga_dobjfunc(M_X, str_labelFileName, varargin)
%
% ARGUMENTS
%
%	M_X			in (matrix)	a matrix of weights where
%							each row corresponds
%							to the weights for a
%							single individual
%	str_labelFileName	string		Filename containing the path
%							or region to optimise
%							toward.
%	verbosity		in (integer)	an optional verbosity
%							setting. If 0,
%							no output is echoed,
%							if 1, only final value
%							if >1, everything.
%
%	F			out (col)	the resultant from the 
%							input M_X, i.e. the cost
%							per row.
%
% DESCRIPTION
%
%	'ga_dobjfunc' is a Genetic Algorithm toolbox wrapper around a
%	dijkstra-based objective function, 'dobjfunc'. As such, it accepts
%	the same arguments as 'dobjfunc'.
%
%	This function merely removes each row in turn from M_X, and passes
%	this to 'dobjfunc', recording the return value in the vector F.
%
% PRECONDITIONS
%	
% 	o <str_labelFileName> must contain a valid FreeSurfer label format
%	  file.
%
% POSTCONDITIONS
%
%	o the objective value 'F' for each row-weight in M_X.
%
% HISTORY
% 22 March 2005
% o Initial conceptualisation.
%
% 01 April 2005
% o Adpated to stand-alone.
%

[rows, cols]		= size(M_X);
F			= zeros(rows, 1);
verbosity    		= 0;
if length(varargin)
    verbosity		= varargin{1};
end

fprintf(1, 'Member:\t\t\t');
for member = 1:rows
    fprintf(1, '%d ', member);
    V_X	= M_X(member, :);
    F(member) = dobjfunc(V_X, str_labelFileName, verbosity);
end
fprintf(1, '\n');
