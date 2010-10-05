function [aM] =	poly_connect(aM_P, varargin)
%
% NAME
%
%  function [av] =	points_connect(aM_P <, ax_col, a_numConnect>)
%
% ARGUMENTS
% INPUT
%	aM_P		matrix		Polygon
%
% OPTIONAL
%	ax_col		int		the column in the polygon matrix
%					that is interpolated
%	a_numConnect	int		number of intermediate points
%					connecting each segement betweeen
%					points of the polygon
%
% OUTPUTS
%	aM		matrix		table of points that linearly
%					connect the points of the polygon
%
% DESCRIPTION
%
%	'poly_connect' linearly connects each point of the input polygon.
%	The input matrix, aM_P, defines the vertices of a polygon. The
%	connecting / intermediate points between each vertex are 
%	returned by this function.
%
% PRECONDITIONS
%
%	o a_numConnect defines the number of points along each polygon 
%	  segment. If omitted, then the interpolation is assumed to be 
%	  over the integer difference between successive points in the 
%	  first column of aM.
%
% POSTCONDITIONS
%
%	o Matrix (i.e. table) of interconnecting points is returned.
%
% NOTE:
%	This function mimics the built in MatLAB 'interp1'. If each column
%	of the input polygon is separated into its own vector (x and y in
%	the 2D case), and if a set of intermediate points xi are defined, 
%	this function returns identical results to:
%
%		yi  = interp1(x, y, xi)
%		aM1 = [xi yi]
%
%		P   = [x' y']
%		aM2 = poly_connect(P)
%
%		aM1 == aM2
%
% HISTORY
% 17 May 2007
% o Initial design and coding.
%
%

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

	function vprintf(level, str_msg)
	    if verbosity >= level
		fprintf(1, str_msg);
	    end
	end

%%%%%%%%%%%%%% 
%%% Nested functions :END
%%%%%%%%%%%%%% 

x_col		= 1;
b_userPoints	= 0;
if length(varargin)
    x_col		= varargin{1};
    if length(varargin) == 2
        b_userPoints 	= 1;
        a_numConnect	= varargin{2};
    end
end

[rows cols]		= size(aM_P);
for edge = 1:rows-1
    v_P1	= aM_P(edge,:);
    v_P2	= aM_P(edge+1,:);
    if ~b_userPoints
	a_numConnect = abs(v_P2(x_col) - v_P1(x_col)) - 1;
    end
    M_edge	= points_connect(v_P1, v_P2, a_numConnect);
    if edge == 1
	aM	= M_edge;
    else
	[aMrows, aMcols]	= size(aM);
	[M_edgeRows, M_edgeCols]= size(M_edge);
	aMnew 	= zeros(aMrows + M_edgeRows-1, aMcols);
	[aMnewRows, aMnewCols]	= size(aMnew);
	aMnew(1:aMrows, :)			= aM;
	aMnew(aMrows:aMnewRows, :)		= M_edge;
	aM	= aMnew;
    end
end


end