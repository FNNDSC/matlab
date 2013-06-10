function Fext=GVFOptimizeImageForces3D(Fext, Mu, Iterations, Sigma)
% This function "GVFOptimizeImageForces" does gradient vector flow (GVF)
% on a vector field. GVF gives the edge-forces a larger capature range,
% to make the snake also reach concave regions
%
% Fext = GVFOptimizeImageForces3D(Fext, Mu, Iterations, Sigma) 
% 
% inputs,
%   Fext : The image force vector field N x M x 3
%   Mu : Is a trade of scalar between noise and real edge forces
%   Iterations : The number of GVF itterations
%   Sigma : Used when calculating the Laplacian
% 
% outputs,
%   Fext : The GVF optimized image force vector field
%
% Function is written by D.Kroon University of Twente (July 2010)

% Squared magnitude of force field
Fx= Fext(:,:,:,1);
Fy= Fext(:,:,:,2);
Fz= Fext(:,:,:,3);

% Calculate magnitude
sMag = Fx.^2+ Fy.^2 + Fz.^2;

% Set new vector-field to initial field
u=Fx; v=Fy; w=Fz;

% Iteratively perform the Gradient Vector Flow (GVF)
for i=1:Iterations,
  % Calculate Laplacian
  Uxx=ImageDerivatives3D(u,Sigma,'xx');
  Uyy=ImageDerivatives3D(u,Sigma,'yy');
  Uzz=ImageDerivatives3D(u,Sigma,'zz');

  % Update the vector field
  u = u + Mu*(Uxx+Uyy+Uzz) - sMag.*(u-Fx);
  clear('Uxx','Uyy','Uzz');
  
  Vxx=ImageDerivatives3D(v,Sigma,'xx');
  Vyy=ImageDerivatives3D(v,Sigma,'yy');
  Vzz=ImageDerivatives3D(v,Sigma,'zz');
   
  v = v + Mu*(Vxx+Vyy+Vzz) - sMag.*(v-Fy);
  clear('Vxx','Vyy','Vzz');
  
  Wxx=ImageDerivatives3D(w,Sigma,'xx');
  Wyy=ImageDerivatives3D(w,Sigma,'yy');
  Wzz=ImageDerivatives3D(w,Sigma,'zz');
  
  w = w + Mu*(Wxx+Wyy+Wzz) - sMag.*(w-Fz);
  clear('Wxx','Wyy','Wzz');
end

Fext(:,:,:,1) = u;
Fext(:,:,:,2) = v;
Fext(:,:,:,3) = w;