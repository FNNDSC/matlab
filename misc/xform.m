function [p_sd] = xform(p_poser,par,front,align);
% this function is the transformation from poser to sd/fast
%
% Input:
%   p_poser........XYZ coordinates in the poser model
%   par............Parameters of the transformation
%                  1-3: translation
%                  4: scaling
%                  5-6: rotation
%   front..........indicates front side of SD/FAST model (only Y and -X are supported now)
%
% extract parameters:
Translation = par(1:3)';
Scale = par(4);
alpha = par(5);
beta = par(6);

% create rotation matrices
Ry_beta = [ cos(beta) 0 sin(beta);
                0     1     0    ;
           -sin(beta) 0 cos(beta)];

Ry_alpha = [ cos(alpha) 0 sin(alpha);
                0     1     0    ;
           -sin(alpha) 0 cos(alpha)];

Rx_alpha = [    1       0         0      ;
                0  cos(alpha) -sin(alpha);
                0  sin(alpha)  cos(alpha)];

Rz_beta = [cos(beta)  -sin(beta)    0  ;
           sin(beta)  cos(beta)     0  ;
               0         0          1 ];

Rz_90 = [0 -1 0 ; 1 0 0; 0 0 1];
Rz_180 = [-1 0 0 ; 0 -1 0; 0 0 1];
Rz_270  = [0 1 0 ; -1 0 0; 0 0 1];
Rx_90 = [1 0 0; 0 0 -1; 0 1 0];
Rx_270 = [1 0 0; 0 0 1; 0 -1 0];

Ry_90 = [ -1 0 0 ; 0 0 1; 0 1 0];

% Do transformation
%p_sd = Translation + Scale*Rz_beta*Ry_alpha*Rx_270*Rz_90*p_poser;		% Rudolph's thigh & shank segments
p_sd = Translation + Scale*Rz_beta*Ry_alpha*Rx_270*Ry_90*p_poser;		% Rudolph's foot segments
%p_sd = Translation + Scale*Ry_beta*Rx_alpha*Rx_270*Rz_90*p_poser;	    % Rudolph's upper body


