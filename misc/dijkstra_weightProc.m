function [a_x]	= dijkstra_weightProc(a_X, varargin)
% NAME
%
%	function [x]	= dijkstra_weightProc(a_X [, af_cutoff])
%
% ARGUMENTS
%
%	INPUT
%	a_X		matrix		a matrix (mxn) of binary weights - each
%					row represents a single observation (1..m)
%					of an n-dimensional binary weight vector.
%	OPTIONAL INPUT
%	af_cutoff	float 		a cutoff value (0... 1) used to determine
%					membership of a candidate bit in the final
%  					weight vector.
%			
%	OUTPUT
%	a_x		vector		
%
% DESCRIPTION
%
%	'dijkstra_weightProc' processes a binary weight matrix and returns
%	a single row vector that is "representative" of the entire matrix.
%
%	Essentially each column is summed and normalised to the amount of rows
%	in the input matrix. Then, based on <cutoff> each bit position is 
%	the binary result of <bit>=(<normal> >= <cutoff>) ? 1 : 0
%
%	This function is also available as an awk script, 
%	sulcus_weightProc.awk.
%
% PRECONDITIONS
%
%	o The input matrix X is (m x 9) of binary values
%
% POSTCONDITIONS
%
%	o Output is a single row vector that is the result of a
%	  summation/normalisation/cutoff.
%
% SEE ALSO
%
%	o sulcus_weightProc.awk
%
% HISTORY
% 19 January 2006
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


f_cutOff	= 0.5;

if length(varargin)
	f_cutOff	= varargin{1};
	if ~isnumeric(f_cutOff)
            error_exit('checking on cutOff value',              ...
                        'value must be numeric and between 0 and 1', ...
                        '10');
        end

end


[rows cols]	= size(a_X);
a_x		= zeros(1, cols);
colSum		= sum(a_X);
colSumN 	= colSum ./ rows;
P		= find(colSumN >= f_cutOff);
[rowsp colsp]	= size(P);
for i=1:colsp
	a_x(P(i)) = 1;
end


end