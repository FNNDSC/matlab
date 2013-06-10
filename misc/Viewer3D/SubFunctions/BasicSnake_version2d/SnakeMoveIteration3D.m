function FV=SnakeMoveIteration3D(B,FV,Fext,gamma,kappa,delta,lambda)
% This function will calculate one iteration of contour Snake movement
%
% FV=SnakeMoveIteration2D(S,FV,Fext,gamma,kappa)
%
% inputs,
%   B : Internal force (smoothness) matrix
%   FV : The triangulated surface
%   Fext : External vector field (from image)
%   gamma : Time step
%   kappa : External (image) field weight
%   delta : Balloon Force weight
%   lambda: Weight which changes the direction of the image  potential force 
%           to the direction of the surface normal, value default 0.8 
%           (range [0..1]) (Keeps the surface from self intersecting)
%
% outputs,
%   P : The (moved) contour points N x 2;
%
% Function is written by D.Kroon University of Twente (July 2010)

V=FV.vertices;

% Clamp contour to boundary
V(:,1)=min(max(V(:,1),1),size(Fext,1));
V(:,2)=min(max(V(:,2),1),size(Fext,2));
V(:,3)=min(max(V(:,3),1),size(Fext,3));

% Get image force on the contour points
Fext1(:,1)=kappa*interp3(Fext(:,:,:,1),V(:,2),V(:,1),V(:,3));
Fext1(:,2)=kappa*interp3(Fext(:,:,:,2),V(:,2),V(:,1),V(:,3));
Fext1(:,3)=kappa*interp3(Fext(:,:,:,3),V(:,2),V(:,1),V(:,3));

% Interp3, can give nan's if contour close to border
Fext1(isnan(Fext1))=0;

% Calculate the baloonforce on the contour points
N=PatchNormals3D(FV);
Fext2=delta*N;

% This is the potential force, but only the component in the  direction of 
% the surface normal
Fext3=repmat(dot(Fext1,N,2),1,3).*N;

V(:,1)=B * V(:,1) + gamma * (Fext1(:,1)*(1-lambda) + Fext3(:,1)*lambda + Fext2(:,1));
V(:,2)=B * V(:,2) + gamma * (Fext1(:,2)*(1-lambda) + Fext3(:,2)*lambda + Fext2(:,2));
V(:,3)=B * V(:,3) + gamma * (Fext1(:,3)*(1-lambda) + Fext3(:,3)*lambda + Fext2(:,3));

% Clamp contour to boundary
V(:,1)=min(max(V(:,1),1),size(Fext,1));
V(:,2)=min(max(V(:,2),1),size(Fext,2));
V(:,3)=min(max(V(:,3),1),size(Fext,3));
    
FV.vertices=V;