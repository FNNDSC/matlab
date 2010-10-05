function [xy, Dxy] = spiral_indicesDetermine(r)
% NAME
%
%	function [Dxy] = spiral_indicesDetermine(r)
%
% ARGUMENTS
%	INPUT
%	r			scalar		the radius (square) in which
%							to determine indices
%
%	OUTPUT
%	xy			out (matrix)	a table of absolute (x, y)
%							positions tracing a
%							square spiral
%	Dxy			out (matrix)	a table of delta 'x' and 'y'
%							positions to trace out
%							a spiral of radius <r>
% DESCRIPTION
%
%	'spiral_indicesDetermine' starts at a hypothetical point (x,y) of
%	(0, 0) and returns the recursive change in (x,y) indices to trace out
%	a square spiral. x is assumed to increase left->right, y increases
%	top->bottom.
%
% PRECONDITIONS
%	
% 	o None.
%
% POSTCONDITIONS
%
%	o A table is returned that contains the changes to each (xi, yi)
%	  where:
%
%		(xj, yj) = (xi, yi) + Dxy(i); j=i+1
%
% HISTORY
% 23 May 2005
% o Initial design and coding.
%

sideLength 	= 1;
xyIndex		= 2;
xy		= zeros((2*r+1)^2, 2);
Dxy		= zeros((2*r+1)^2, 2);
xy(1, 1)	= 0;
xy(1, 2)	= 0;
Dxy(1, 1)	= 0;
Dxy(1, 2)	= 0;

while (1)
    for onOff=0:1
	for side=1:sideLength
	    if(mod(sideLength, 2))
	    	signum = 1;
	    else
	    	signum = -1;
	    end
 	    Dxy(xyIndex, 1)	= ~(onOff && signum) * signum;
	    Dxy(xyIndex, 2)	=  (onOff && signum) * signum;
	    xy(xyIndex, 1)	= xy(xyIndex-1, 1) + Dxy(xyIndex, 1);
	    xy(xyIndex, 2)	= xy(xyIndex-1, 2) + Dxy(xyIndex, 2);
	    xyIndex		= xyIndex + 1;
	    if(xyIndex > (2*r+1)^2)
	 	return
	    end
	end
    end
    sideLength = sideLength + 1;
end
