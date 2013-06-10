function P=MakeContourClockwise2D(P)
% This function MakeContourClockwise will make a contour clockwise 
% contour clockwise. This is done by calculating the area inside the 
% contour, if it is positive we change the contour orientation.
%
%  P=MakeContourClockwise2D(P);
%
% Function is written by D.Kroon University of Twente (July 2010)

% Area inside contour
O=[P;P(1:2,:)];
area = 0.5*sum((O((1:size(P,1))+1,1) .* (O((1:size(P,1))+2,2) - O((1:size(P,1)),2))));

% If the area inside  the contour is positive, change from counter-clockwise to 
% clockwise
if(area>0), P=P(end:-1:1,:); end
