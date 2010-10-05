function [F] = TSfft3D(a_trials, a_rows, a_cols, a_slices, varargin)
%
% SYNOPSIS
%  	function [F] = TSfft3D(a_trials, a_rows, a_cols, a_slices ...
%			[, ab_force2D])
%
% ARGS
%   a_trials        	in      number of trials to run
%   a_rows          	in      number of rows
%   a_cols          	in      number of columns
%   a_slices        	in      number of slices
%   ab_force2D		in	if specified, perform a 2D FFT on each
%					slice; i.e. do not perform a
%					volume FFT. Note that *any* value
%					can be passed in this field. The
%					presence of a variably, not its
%					value toggles the 2D/3D behaviour.
%
%   F               	out     FFT output
%
% DESC
%   	Does a quick and dirty speed trial on some 3D FFT function calls.
%	If the optional <ab_force2D> is specified (regardless of its value),
%	each slice of the volume is FFT'd. The default behaviour is to FFT
%	the entire data in a volumetric manner.
%
% NOTE
%	If comparing output to the compiled test suite process of the 
%	'cppmatrixt' project, note that MatLAB is column dominant, and
%	C/C++ row dominant.
%
%	This means that MatLAB matrices should be transposed if a comparison
%	to the compiled process output is desired.
%
% HISTORY
% 22 April 2003
%   o Initial design and coding based on TSfft.cpp
%
% 25 May 2006
%   o Added ab_force2D
%

M_A = dataSet3D_create(a_rows, a_cols, a_slices);

b_2D	= 0;
if length(varargin)
	b_2D	= 1;
end


fprintf(1, 'Number of trial fft calls FFT(M_A) :\t%d\n', a_trials);
dims    = size(M_A);
fprintf(1, 'Matrix size:\t\t\t\t%d x %d x %d\n', dims(1,1), dims(1,2), a_slices);

startTime   = cputime;
if b_2D
    for k=1:a_trials,
	for slice=1:a_slices
	    %F(:,:,slice) = fftshift(ifftn(ifftshift(M_A(:,:,slice))));
	    F(:,:,slice) = ifftn(M_A(:,:,slice));
	end
    end
else
    for k=1:a_trials,
        %F = fftshift(ifftn(ifftshift(M_A)));
        F = ifftn(M_A);
    end
end


totalTime    = cputime - startTime;
fprintf(1, 'Total time for MatLAB FFT(M_A):\t\t%f seconds - or %f seconds per trial\n', ...
        totalTime, totalTime/a_trials);




