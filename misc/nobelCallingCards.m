%
% DESC
%
% Plot the calling card rates for various Nobel cellular cards to South Africa
%
% HISTORY
% 04 September 2003
%   o Initial design and coding
%


T=1:60*60;

plot(   T/60, phoneRate(60*60, 4*60, .134/60), 'r', ...
        T/60, phoneRate(60*60, 2*60, .144/60), 'g', ...
        T/60, phoneRate(60*60, 1*60, .17/60), 'b', ...
        T/60, phoneRate(60*60, 1, .20/60), 'k');

grid;


