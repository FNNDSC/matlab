function [R] = phoneRate(a_time, a_increment, a_price)
%
% SYNOPSIS
%  	function [R] = phoneRate(a_time, a_increment, a_price)
%
% ARGS
%   a_time          in      time (in seconds) over which to plot rates
%   a_increment     in      billing increment (seconds)
%   a_price         in      price (per second)
%
%   R               out     rates over a_time
%
% DESC
%
%   A very simple rate calculator. Given a time frame (a_time), returns
%   a vector of prices over that time frame. This vector is a function
%   of the billing increment as well as the price per second.
%
% HISTORY
% 04 September 2003
%   o Initial design and coding
%

T   = 1:a_time;

for i=1:a_time
    wholeCycles = floor(i/a_increment);
    if mod(i, a_increment) > 1
        partialCycles = 1;
    else
        partialCycles = 0;
    end

    T(i) = (wholeCycles + partialCycles)*a_increment;
end

R   = a_price*T;




