function K=InterpolateContourPoints2D(P,nPoints)
% This function resamples a few points describing a countour , to a smooth
% contour of uniform sampled points.
%
% K=InterpolateContourPoints(P,nPoints)
%
% input,
%  P : Inpute Contour, size N x 2  (with N>=4)
%  nPoints : Number of Contour points as output
% 
% output,
%  K : Uniform sampled Contour points, size nPoints x 2
%
% Function is written by D.Kroon University of Twente (July 2010)
%
% example, 
%  % Show an image
%   figure, imshow(imread('moon.tif'));
%  % Select some points with the mouse
%   [y,x] = getpts;
%  % Make an array with the clicked coordinates
%   P=[x(:) y(:)];
%  % Interpolate inbetween the points
%   Pnew=InterpolateContourPoints2D(P,100)
%  % Show the result
%   hold on; plot(P(:,2),P(:,1),'b*');
%   plot(Pnew(:,2),Pnew(:,1),'r.');
%
% Function is written by D.Kroon University of Twente (July 2010)

% Interpolate points inbetween
O(:,1)=interp([P(end-3:end,1);P(:,1);P(:,1);P(1:4,1)],10);
O(:,2)=interp([P(end-3:end,2);P(:,2);P(:,2);P(1:4,2)],10);
O=O(41:end-39,:); 

% Calculate distance between points
dis=[0;cumsum(sqrt(sum((O(2:end,:)-O(1:end-1,:)).^2,2)))];

% Resample to make uniform points
K(:,1) = interp1(dis,O(:,1),linspace(0,dis(end),nPoints*2));
K(:,2) = interp1(dis,O(:,2),linspace(0,dis(end),nPoints*2));
K=K(round(end/4):round(end/4)+nPoints-1,:);

 
 