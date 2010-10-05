function [V] = dataSet1D_create(a_cols)
%
% SYNOPSIS
%  	function [V] = dataSet1D_create(a_cols)
%
% ARGS
%   a_cols          in      number of columns
%
%   v               out     vector output
%
% DESC
%   Creates a vector data set to be used by FFT routines. This vector
%   is created in a manner analogous to the MKL example code, allowing
%   easy comparison with MKL processes.
%
% HISTORY
% 03 September 2003
%   o Initial design and coding based on TSfft.cpp
%


vstep   = (2*pi)/a_cols;
V       = -pi:vstep:pi-vstep;
V       = (sin(V)*sqrt(3))/2 +i*sin(V)/sqrt(3);




