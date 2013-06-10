function J=ImageDerivatives2D(I,sigma,type)
% Gaussian based image derivatives
%
%  J=ImageDerivatives2D(I,sigma,type)
%
% inputs,
%   I : The 2D image
%   sigma : Gaussian Sigma
%   type : 'x', 'y', 'xx', 'xy', 'yy'
%
% outputs,
%   J : The image derivative
%
% Function is written by D.Kroon University of Twente (July 2010)

% Make derivatives kernels
[x,y]=ndgrid(floor(-3*sigma):ceil(3*sigma),floor(-3*sigma):ceil(3*sigma));

switch(type)
    case 'x'
        DGauss=-(x./(2*pi*sigma^4)).*exp(-(x.^2+y.^2)/(2*sigma^2));
    case 'y'
        DGauss=-(y./(2*pi*sigma^4)).*exp(-(x.^2+y.^2)/(2*sigma^2));
    case 'xx'
        DGauss = 1/(2*pi*sigma^4) * (x.^2/sigma^2 - 1) .* exp(-(x.^2 + y.^2)/(2*sigma^2));
    case {'xy','yx'}
        DGauss = 1/(2*pi*sigma^6) * (x .* y)           .* exp(-(x.^2 + y.^2)/(2*sigma^2));
    case 'yy'
        DGauss = 1/(2*pi*sigma^4) * (y.^2/sigma^2 - 1) .* exp(-(x.^2 + y.^2)/(2*sigma^2));
end

J = imfilter(I,DGauss,'conv','symmetric');
