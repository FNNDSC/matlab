function [av_c] = centroidND_find(aM_x, varargin)
%
% NAME
%
%	function [av_c] = centroidND_find(aM_x [, ab_Xcentroids])
%
% ARGUMENTS
%
%	INPUT
%	aM_x		matrix			a column dominant matrix. This
%						defines a shape in N-space 
%						where N = cols(aM_x) is the
%						dimensionality of the space
%						and cols(1:N-1) define points
%						of this object, each "point"
%						has a value aM_x(N). For higher
%						dimensional spaces, the rows
%						of the matrix are equal to
%						m^N.
%
% 	OPTIONAL
%	ab_Xcentroids	bool			specifies if the "X" vector
%						field denotes the position of
%						centroids. If false, then
%						X field centroids are placed
%						equadistant between X 
%						successive coords.
%
%
%	OUTPUT
%	av_c		vector			The centroid of each column of
%						aM_x.		
%
% DESCRIPTION
%
%	'centroidND_find' returns the centroid of an object defined in an
%	arbitrary N-space (N=cols(aM_x)). The first N-1 columns define the
%	coordinate axes of the space, i.e. the 'X' vector field, and the
%	last column defines the function values, i.e. f(X).
%
% PRECONDITIONS
%
%	o aM_x describes a 'shape'. This shape is made up of the sum of
%	  N-d 'rectangles'.
%	o The function described by aM_x should describe a single enclosed 
%	  N-space, i.e. every element in aM_x must be defined.
%	o The N-1 columns of aM_x must have fixed d(n) separating successive
%	  points.
%	o The shape to analyze is assumed to be comprised of rectangular
%	  strips of "area" denoted by the last column of aM_x, with 
%	  the preceding columns denoting the position in N-1 space of the
%	  area strip.
%
% POSTCONDITIONS
%
%	o The centroid of the space described by aM_x is returned.
% 
% SEE ALSO
%
% HISTORY
% 24 July 2006
% o Initial design and coding.
%

b_Xcentroids	= 0;
if length(varargin)
    b_Xcentroids = varargin{1};
end


[xrows xcols]	= size(aM_x);
str_name	= 'centroidND_find';
if xrows < 2
    error_exit(	'checking rows in shape',		...
		'there must be at least 2 rows',	...
		'1');
end

av_c		= zeros(1, xcols);

% This algorithm is built around the concept of rectangular strips
% that taken together define the object to be analyzed. We assume that
% the N-1 cols of aM_x are the 'x' positions in the N-space. The 'y'
% position of any particular stip's centroid is thus the f(X) value 
% (contained in column N) divided by 2. We insert an extra column for
% this y-position strip centroid. 
M_x		= zeros(xrows, xcols+1);
M_x(:,1:xcols)	= aM_x;
v_fX		= aM_x(:, xcols);
M_x(:, xcols+1)	= v_fX;
M_x(:, xcols)	= M_x(:, xcols) ./ 2;

% for each "strip", define the "centroid" at the center of the rectangular
% space, (xi+0.5dxi, M_x(xcols))

M_xcoords	= M_x(:,1:xcols-1);
v_dn		= zeros(1, xcols-1);
for col=1:xcols-1
    v_dn(col)	= M_xcoords(2, col) - M_xcoords(1, col);
%      v_dn1(col)	= M_xcoords(xrows, col) - M_xcoords(xrows-1, col)
%      if v_dn1(col) ~= v_dn(col)
%  	error_exit(sprintf('checking points in col %d', col),	...
%  		   'intra-point spacing appears non-uniform',	...
%  		   '2');
%      end
end

if b_Xcentroids
    M_stripcentroidX		= M_xcoords;
else
    M_stripcentroidX		= repmat(v_dn./2, xrows, 1) + M_xcoords;
end
v_stripcentroidY		= M_x(:, xcols);
M_stripcentroid			= zeros(xrows, xcols);
M_stripcentroid(:,1:xcols-1)	= M_stripcentroidX;
M_stripcentroid(:,xcols)	= v_stripcentroidY;

% and the area of each strip is base*height, i.e. dxi * M_x(xcols+1)
M_xdelArea			= repmat(v_dn, xrows, 1);
M_fX				= repmat(v_fX, 1, xcols-1);
M_area				= abs(M_xdelArea .* M_fX);

% X direction:
M_xweightedArea			= M_stripcentroidX .* M_area;
v_xweightedAreaSum		= sum(M_xweightedArea);

% y direction
v_yweightedArea			= v_stripcentroidY .* M_area(:,1);
yweightedAreaSum		= sum(v_yweightedArea);

v_weightedAreaSum		= zeros(1, xcols);
v_weightedAreaSum(1:xcols-1)	= v_xweightedAreaSum;
v_weightedAreaSum(xcols)	= yweightedAreaSum;

v_areaSum			= sum(M_area);

try
        av_c			= v_weightedAreaSum ./ v_areaSum;
catch ME1
    % When an input function is defined point-by-point in a vector
    % field, an additional dimension is implicit. Consider a 2D image
    % that is described as a 3D object, [X1' X2' f(X1,X2)]. In such
    % cases the 'v_areaSum' is missing a weight for the final
    % dimension. We simply extend the v_areaSum along this dimensional
    % index.
        v_areaSum(numel(v_areaSum)+1) = v_areaSum(numel(v_areaSum));
        av_c                    = v_weightedAreaSum ./ v_areaSum;
end






