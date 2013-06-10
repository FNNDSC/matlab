function Fext=GVFOptimizeImageForces2D(Fext, Mu, Iterations, Sigma)
% This function "GVFOptimizeImageForces" does gradient vector flow (GVF)
% on a vector field. GVF gives the edge-forces a larger capature range,
% to make the snake also reach concave regions
%
% Fext = GVFOptimizeImageForces2D(Fext, Mu, Iterations, Sigma) 
% 
% inputs,
%   Fext : The image force vector field N x M x 2
%   Mu : Is a trade of scalar between noise and real edge forces
%   Iterations : The number of GVF itterations
%   Sigma : Used when calculating the Laplacian
% 
% outputs,
%   Fext : The GVF optimized image force vector field
%
% Function is written by D.Kroon University of Twente (July 2010)

% Squared magnitude of force field
Fx= Fext(:,:,1);
Fy= Fext(:,:,2);

% Calculate magnitude
sMag = Fx.^2+ Fy.^2;

% Set new vector-field to initial field
u=Fx;  v=Fy;
  
% Iteratively perform the Gradient Vector Flow (GVF)
for i=1:Iterations,
  % Calculate Laplacian
  Uxx=ImageDerivatives2D(u,Sigma,'xx');
  Uyy=ImageDerivatives2D(u,Sigma,'yy');
  
  Vxx=ImageDerivatives2D(v,Sigma,'xx');
  Vyy=ImageDerivatives2D(v,Sigma,'yy');

  % Update the vector field
  u = u + Mu*(Uxx+Uyy) - sMag.*(u-Fx);
  v = v + Mu*(Vxx+Vyy) - sMag.*(v-Fy);
end

Fext(:,:,1) = u;
Fext(:,:,2) = v;
