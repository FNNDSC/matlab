%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function Developed by Fahd A. Abbasi.
% Department of Electrical and Electronics Engineering, University of
% Engineering and Technology, Taxila, PAKISTAN.                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function takes a picture as an argument (suitably should contain only one 
% object whose centroid is to be obtained) and returns the x and y
% coordinates of its centroid.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% USAGE (SAMPLE CODE)
% 
%   pic = imread('ic.tif');
%   [x,y] = ait_centroid(pic);
%   x
%   y
%   imshow(pic); pixval on
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [meanx,meany] = ait_centroid(pic)

    
[x,y,z] = size(pic);          % Checking whether the picture is colored or monochromatic, if colored then converting to gray.
if(z==1)
    ;
else
    pic = rgb2gray(pic);
end


im = pic;
[rows,cols] = size(im);
x = ones(rows,1)*[1:cols];    % Matrix with each pixel set to its x coordinate
y = [1:rows]'*ones(1,cols);   %   "     "     "    "    "  "   "  y    "

area = sum(sum(im));
meanx = sum(sum(double(im).*x))/area;
meany = sum(sum(double(im).*y))/area;
