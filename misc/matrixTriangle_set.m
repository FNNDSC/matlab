function [aM_out] = matrixTriangle_set(aM_in, af_val, varargin)
%
% NAME
%	function [aM_out] = matrixTriangle_set(aM_in, af_val, <astr_triangle>)
%
%
% ARGUMENTS
%       
%       INPUT
%       aM_in           matrix          square matrix
%       af_val          float           value to assign to upper or lower
%                                       triangle of matrix
%       
%       OPTIONAL
%       astr_triangle   string          one of 'upper' or 'lower' defining
%                                       which triangle to set to <af_val>;
%                                       defaults to 'upper'
%       
%       OUTPUT
%
% DESCRIPTION
%
%       'matrixTriangle_set' sets the 'upper' or 'lower' triangle 
%       to <af_val>.
%
% PRECONDITIONS
%       o aM_in must be square.
%
% POSTCONDITIONS
%       o Trianglized matrix returned in aM_out.
%
% HISTORY
% 04 November 2010
% o Initial design and coding.
% 
%

% ---------------------------------------------------------

%%%%%%%%%%%%%% 
%%% Nested functions :START
%%%%%%%%%%%%%% 
	function error_exit(	str_action, str_msg, str_ret)
		fprintf(1, '\tFATAL:\n');
		fprintf(1, '\tSorry, some error has occurred.\n');
		fprintf(1, '\tWhile %s,\n', str_action);
		fprintf(1, '\t%s\n', str_msg);
		error(str_ret);
	end

%%%%%%%%%%%%%% 
%%% Nested functions :END
%%%%%%%%%%%%%% 


b_upper         = 1;
str_triangle    = 'upper';
% Parse optional arguments
if length(varargin) >= 1, str_triangle = varargin{1};	end

if ~strcmp(str_triangle, 'upper'), b_upper = 0; end

[rows cols] = size(aM_in);

if rows ~= cols
    error_exit('checking on inputs', 'the input matrix must be square', '1');
end

aM_out  = aM_in;
for row=1:rows
    for col=1:cols
        if b_upper
            if col>row, aM_out(row, col) = af_val; end
        else
            if col<row, aM_out(row, col) = af_val; end
        end
    end
end

end
% ---------------------------------------------------------


