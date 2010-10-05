function [H] = sawTooth(f_startE, f_minE, f_delE)
%
% SYNOPSIS
%   [H] = sawTooth(f_startE, f_minE, f_delE)
%
% ARGS
%   f_startE    in      starting exponent
%   f_minE      in      min decay for exponent
%   f_delE      in      change in exponent
%   H           out     trajectory data
%
% DESC
%   This function merely shows a re-initialised
%   exponential decay graph.
%

samples = 1000;
t       = 1:samples;
H       = zeros(1,1000);

f_e     = f_startE;
for i = 1:samples
    H(i)    = f_e;
    f_e     = f_e * f_delE;
    if f_e <= f_minE
        f_e = f_startE;
    end
end

