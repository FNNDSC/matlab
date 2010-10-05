function [y] = mbf(X)
%
% ARGS
%   X       in      vector of "domain" values
%
% DESC
%   Determine the MB/f over the given X domain that
%   will allow for 30 fps.
%
%   In order to maintain a 30 frames per second display
%   rate in an environment where information is transmitted
%   over a network, the network bandwidth acts as a 
%   limiting factor on the size (in MB) of frames
%   that are transmitted.
%
%   This function simply graphs the size of individual frames
%   against network bandwith (the `X', assumed to be in MB/s).
%   Each frame is considered to be a square of n x n pixels.
%
%   Several plots are generated: one for "pure" data as an
%   asymptotic graph - i.e. no colour depth. Other graphs are
%   for 1, 2, 4, and 8 color bit depths.
%
%   Note that these are absolute theoretical *transission* limits:
%   the lagging effect of encoding and decoding at each end of the 
%   communication pipe are not considered. 
%

p0  = sqrt(X/30);
p2  = sqrt(X/30/2);
p4  = sqrt(X/30/4);
p8  = sqrt(X/30/8);

figure(1);
plot(X, p0, 'k-', X, p2, 'k:', X, p4, 'k-.', X, p8, 'k--');
legend('Pure data', 'Colour-depth of 2 bits', 'Colour-depth of 4 bits', 'Colour-depth of 8 bits');
grid

title('Size limits on square frames to maintain 30 fps');
xlabel('Bandwidth in MB/s');
ylabel('Frame side pixel length in kB/f');
