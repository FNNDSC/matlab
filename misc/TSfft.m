function [F] = TSfft(a_trials, a_size)
%
% SYNOPSIS
%  	[F] = TSfft(a_trials, a_size)
%
% ARGS
% 	a_trials        in      number of trials to run
% 	a_size          in      length of vector
%   F               out     FFT output
%
% DESC
%   	Does a quick and dirty speed trial on some FFT function calls.
%
% HISTORY
% 22 April 2003
%   o Initial design and coding based on TSfft.cpp
%

M_A = dataSet1D_create(a_size);

fprintf(1, 'Number of trial fft calls FFT(M_A) :\t%d\n', a_trials);
fprintf(1, 'Vector length:\t\t\t\t%d\n', a_size);

startTime   = cputime;
for k=1:a_trials,
    F = fft(M_A);
end
totalTime    = cputime - startTime;

fprintf(1, 'Total time for MatLAB FFT(M_A):\t\t%f seconds - or %f seconds per trial\n', ...
        totalTime, totalTime/a_trials);




