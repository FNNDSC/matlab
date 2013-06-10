function N=GetContourNormals2D(P)
% This function calculates the normals, of the contour points
% using the neighbouring points of each contour point
%
% N=GetContourNormals2D(P)
% 
% inputs,
%  P : List with contour coordinates M x 2
%
% outputs,
%  N : List with contour normals M x 2
%
% Function is written by D.Kroon University of Twente (July 2010)

% Use the n'th neighbour to calculate the normal (more stable)
a=4;

% From array to separate x,y
xt=P(:,1); yt=P(:,2);

% Derivatives of contour
n=length(xt);
f=(1:n)+a; f(f>n)=f(f>n)-n;
b=(1:n)-a; b(b<1)=b(b<1)+n;

dx=xt(f)-xt(b);
dy=yt(f)-yt(b);

% Normals of contourpoints
l=sqrt(dx.^2+dy.^2);
nx = -dy./l; 
ny =  dx./l;
N(:,1)=nx; N(:,2)=ny;
