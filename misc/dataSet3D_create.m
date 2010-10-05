function [L] = dataSet3D_create(a_rows, a_cols, a_slices, varargin)
%
% SYNOPSIS
%  	function [L] = dataSet3D_create(a_rows, a_cols, a_slices ...
%					[, ab_ordered])
%
% ARGS
%   a_cols          	in      number of columns
%   a_rows          	in      number of rows
%   a_slices        	in      number of slices
%   ab_ordered		in	if present (regardless of value)
%					organise the volume with a column
%					of '1' values along the center
%					of each slice.
%
%   L               	out     volume output
%
% DESC
%   Creates a volume data set to be used by FFT routines. This matrix
%   is created in a manner analogous to the TSfft.cpp program.
%
% HISTORY
% 03 September 2003
%   o Initial design and coding based on TSfft.cpp
%
% 21 January 2004
%   o Added "ordered" structure to data contents
%
% 25 May 2006
%   o Redesigned "ordered" structure handling.
%

L       	= zeros(a_rows, a_cols);
L       	= repmat(L, [1 1 a_slices]);

b_ordered	= 0;
if length(varargin)
	b_ordered	= 1;
end

z	= complex(0, 0);
reval     = 1;
imval	= 1;
if b_ordered
    v_col = ones(a_rows, 1);
    L(:,a_cols/2,:) = v_col;
else
    for k=1:a_slices,
	for j=1:a_cols,
        	for i=1:a_rows,
			z		= complex(reval, imval);
                        L(i, j, k)      = z;
                        reval		= reval+1;
                        imval		= imval-1;
                end
        end
    end
end




