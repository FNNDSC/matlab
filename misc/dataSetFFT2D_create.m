function [M] = dataSetFFT2D_create(a_rows, a_cols)
%
% SYNOPSIS
%  	function [M] = dataSetFFT2D_create(a_cols, a_rows)
%
% ARGS
%   a_rows          in      number of rows
%   a_cols          in      number of columns
%
%   M               out     matrix output
%
% DESC
%   Creates a matrix data set to be used by FFT routines. This matrix
%   is created in a manner analogous to the MKL example code, allowing
%   easy comparison with MKL processes.
%
% HISTORY
% 03 September 2003
%   o Initial design and coding based on TSfft.cpp
%


vstep   = (2*pi)/a_rows;
V       = -pi:vstep:pi-vstep;
V       = (sin(V)*sqrt(3))/2 -i*sin(V)/sqrt(3);
V       = V';

M       = repmat(V, 1, a_cols);





