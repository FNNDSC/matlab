function Eextern = ExternalForceImage3D(I,Wline, Wedge,Sigma)
% Eextern = ExternalForceImage3D(I,Wline, Wedge,Sigma)
% 
% inputs, 
%  I : The image
%  Sigma : Sigma used to calculated image derivatives 
%  Wline : Attraction to lines, if negative to black lines otherwise white
%          lines
%  Wterm : Attraction to terminations of lines (end points) and corners
%
% outputs,
%  Eextern : The energy function described by the image
%
% Function is written by D.Kroon University of Twente (July 2010)

Ix=ImageDerivatives3D(I,Sigma,'x');
Iy=ImageDerivatives3D(I,Sigma,'y');
Iz=ImageDerivatives3D(I,Sigma,'z');

Eline =  imgaussian(I,Sigma);
Eedge = sqrt(Ix.^2 + Iy.^2 + Iz.^2); 

Eextern= (Wline*Eline - Wedge*Eedge); 

