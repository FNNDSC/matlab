function [F] = TSfft2D(a_trials, a_rows, a_cols)
%
% SYNOPSIS
%  	function [F] = TSfft2D(a_trials, a_rows, a_cols)
%
% ARGS
% 	a_trials        in      number of trials to run
% 	a_rows          in      number of rows
%   	a_cols          in      number of columns
%
%   	F               out     FFT output
%
% DESC
%   	Does a quick and dirty speed trial on some 2D FFT function calls.
%
% NOTE
%	If comparing output to the compiled test suite process of the 
%	'cppmatrixt' project, note that MatLAB is column dominant, and
%	C/C++ row dominant.
%
%	This means that MatLAB matrices should be transposed if a comparison
%	to the compiled process output is desired.
%
%
% HISTORY
% 22 April 2003
%   o Initial design and coding based on TSfft.cpp
%

M_A = dataSet2D_create(a_rows, a_cols);


fprintf(1, 'Number of trial fft calls FFT(M_A) :\t%d\n', a_trials);
dims    = size(M_A);
fprintf(1, 'Matrix size:\t\t\t\t%d x %d\n', dims(1,1), dims(1,2));

startTime   = cputime;
for k=1:a_trials,
    F = fftn(M_A);
end
totalTime    = cputime - startTime;

fprintf(1, 'Total time for MatLAB FFT(M_A):\t\t%f seconds - or %f seconds per trial\n', ...
        totalTime, totalTime/a_trials);




