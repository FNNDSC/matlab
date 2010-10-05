function [M] = dataSet2D_create(a_rows, a_cols, varargin)
%
% SYNOPSIS
%  	function [M] = dataSet2D_create(a_cols, a_rows ...
%					[,ab_ordered])
%
% ARGS
%   a_rows          in      number of rows
%   a_cols          in      number of columns
%   ab_ordered          in      if present (regardless of value)
%                                       organise the volume with a column
%                                       of '1' values along the center
%                                       of each slice.
%
%   M               out     matrix output
%
% DESC
%   Creates a simple ordered data set.
%
% HISTORY
% 13 May 2004
%   o Initial design and coding based on TSfft.cpp
%
% 25 May 2006
%   o Redesigned "ordered" structure handling.
%


M	= zeros(a_rows, a_cols);
count	= 1;

b_ordered       = 0;
if length(varargin)
        b_ordered       = 1;
end

reval	= 1;
imval   = 1;

if b_ordered
	v_col 			= ones(a_rows, 1);
	M(:, a_cols/2)		= v_col;	
else
    for row=1:a_rows,
	for col=1:a_cols,
		z               = complex(reval, imval);
		M(row, col)	= z;
                reval           = reval+1;
		imval           = -reval;
	end
    end
end




