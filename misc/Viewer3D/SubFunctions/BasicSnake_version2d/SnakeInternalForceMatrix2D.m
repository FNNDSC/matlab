function B=SnakeInternalForceMatrix2D(nPoints,alpha,beta,gamma)
%
% B=SnakeInternalForceMatrix2D(nPoints,alpha,beta,gamma)
%
% inputs,
%   nPoints : The number of snake contour points
%   alpha : membrame energy  (first order)
%   beta : thin plate energy (second order)
%   gamma : Step Size (Time)
%
% outputs,
%   B : The Snake Smoothness regulation matrix
%
% Function is written by D.Kroon University of Twente (July 2010)

% Penta diagonal matrix, one row:
b(1)=beta;
b(2)=-(alpha + 4*beta);
b(3)=(2*alpha + 6 *beta);
b(4)=b(2);
b(5)=b(1);

% Make the penta matrix (for every contour point)
A=b(1)*circshift(eye(nPoints),2);
A=A+b(2)*circshift(eye(nPoints),1);
A=A+b(3)*circshift(eye(nPoints),0);
A=A+b(4)*circshift(eye(nPoints),-1);
A=A+b(5)*circshift(eye(nPoints),-2);

% Calculate the inverse
B=inv(A + gamma.* eye(nPoints));


