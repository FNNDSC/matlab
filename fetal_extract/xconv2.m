function Y = xconv2(I,G)
% function Y = xconv2(I,G)
%   I: the original image
%   G: the mask to be convoluted
%   Y: the convoluted result (by taking fft2, multiply and ifft2)
% 
%   a similar version of the MATLAB conv2(I,G,'same'),  7/10/95
%   implemented by fft instead of doing direct convolution as in conv2
%   the result is almost same , differences are under 1e-10.
%   However, the speed of xconv2 is much faster than conv2 when
%   gaussian kernel has large standard variation.

%   Chenyang Xu and Jerry L. Prince, 7/10/95, 6/17/97
%   Copyright (c) 1995-97 by Chenyang Xu and Jerry L. Prince
%   Image Analysis and Communications Lab, Johns Hopkins University
%

[n,m] = size(I);
[n1,m1] = size(G);
FI = fft2(I,n+n1-1,m+m1-1);  % avoid aliasing
FG = fft2(G,n+n1-1,m+m1-1);
FY = FI.*FG;
YT = real(ifft2(FY));
nl = floor(n1/2);
ml = floor(m1/2);
Y = YT(1+nl:n+nl,1+ml:m+ml);
