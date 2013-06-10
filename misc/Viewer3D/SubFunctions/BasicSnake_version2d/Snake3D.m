function FV=Snake3D(I,FV,Options)
% This function SNAKE implements the basic snake segmentation. A snake is an 
% active (moving) contour, in which the points are attracted by edges and
% other boundaries. To keep the contour smooth, an membrame and thin plate
% energy is used as regularization.
%
% OV=Snake3D(I,FV,Options)
%  
% inputs,
%   I : An Image of type double preferable ranged [0..1]
%   FV : Structure with triangulated mesh, with list of faces FV.faces N x 3
%        and list of vertices M x 3
%   Options : A struct with all snake options
%   
% outputs,
%   OV : Structure with triangulated mesh of the final surface
%
% options (general),
%  Option.Verbose : If true show important images, default false
%  Options.Gamma : Time step, default 1
%  Options.Iterations : Number of iterations, default 100
%
% options (Image Edge Energy / Image force))
%  Options.Sigma1 : Sigma used to calculate image derivatives, default 2
%  Options.Wline : Attraction to lines, if negative to black lines otherwise white
%                    lines , default 0.04
%  Options.Wedge : Attraction to edges, default 2.0
%  Options.Sigma2 : Sigma used to calculate the gradient of the edge energy
%                    image (which gives the image force), default 2
%
% options (Gradient Vector Flow)
%  Options.Mu : Trade of between real edge vectors, and noise vectors,
%                default 0.2. (Warning setting this to high >0.5 gives
%                an instable Vector Flow)
%  Options.GIterations : Number of GVF iterations, default 0
%  Options.Sigma3 : Sigma used to calculate the laplacian in GVF, default 1.0
%
% options (Snake)
%  Options.Alpha : Membrame energy  (first order), default 0.2
%  Options.Beta : Thin plate energy (second order), default 0.2
%  Options.Delta : Baloon force, default 0.1
%  Options.Kappa : Weight of external image force, default 2
%  Options.Lambda : Weight which changes the direction of the image 
%                   potential force to the direction of the surface
%                   normal, value default 0.8 (range [0..1])
%                   (Keeps the surface from self intersecting)
%
% Literature:
%   - Michael Kass, Andrew Witkin and Demetri TerzoPoulos "Snakes : Active
%       Contour Models", 1987
%   - Christoph Lurig, Leif Kobbelt, Thomas Ertl, "Hierachical solutions
%       for the Deformable Surface Problem in Visualization"
%
% Example,
%
% load testvolume
% load SphereMesh
% Options=struct;
% Options.Verbose=1;
% Options.Wedge=0;
% Options.Wline=-1;
% Options.Alpha=0.5;
% Options.Beta=0.4;
% Options.Kappa=0.5;
% Options.Delta=0.1000;
% Options.Gamma=0.1000;
% Options.Iterations=1500;
% Options.Sigma1=2;
% Options.Sigma2=2;
% Options.Lambda=0.8;
% FV.vertices(:,1)=FV.vertices(:,1)+35;
% FV.vertices(:,2)=FV.vertices(:,2)+25;
% FV.vertices(:,3)=FV.vertices(:,3)+20;
% OV=Snake3D(I,FV,Options)
%
% Function is written by D.Kroon University of Twente (July 2010)

% Process inputs
defaultoptions=struct('Verbose',false,'Wline',0.04,'Wedge',2,'Sigma1',2,'Sigma2',2,'Alpha',0.2,'Beta',0.2,'Delta',0.1,'Gamma',1,'Kappa',2,'Iterations',100,'GIterations',0,'Mu',0.2,'Sigma3',1,'Lambda',0.8);
if(~exist('Options','var')), 
    Options=defaultoptions; 
else
    tags = fieldnames(defaultoptions);
    for i=1:length(tags)
         if(~isfield(Options,tags{i})), Options.(tags{i})=defaultoptions.(tags{i}); end
    end
    if(length(tags)~=length(fieldnames(Options))), 
        warning('snake:unknownoption','unknown options found');
    end
end

% Convert input to single if xintxx
if(~strcmpi(class(I),'single')&&~strcmpi(class(I),'double'))
    I=single(I);
end

% The surface faces must always be clockwise (because of the balloon force)
FV=MakeContourClockwise3D(FV);

% Transform the Image into an External Energy Image
Eext = ExternalForceImage3D(I,Options.Wline, Options.Wedge,Options.Sigma1);

% Make the external force (flow) field.
Fx=ImageDerivatives3D(Eext,Options.Sigma2,'x');
Fy=ImageDerivatives3D(Eext,Options.Sigma2,'y');
Fz=ImageDerivatives3D(Eext,Options.Sigma2,'z');

Fext(:,:,:,1)=-Fx*2*Options.Sigma2^2;
Fext(:,:,:,2)=-Fy*2*Options.Sigma2^2;
Fext(:,:,:,3)=-Fz*2*Options.Sigma2^2;

% Do Gradient vector flow, optimalization
Fext=GVFOptimizeImageForces3D(Fext, Options.Mu, Options.GIterations, Options.Sigma3);

% Show the image, contour and force field
if(Options.Verbose)
     drawnow; pause(0.1);
     h=figure; set(h,'render','opengl')
     subplot(2,3,1),imshow(squeeze(Eext(:,:,round(end/2))),[]);
     subplot(2,3,2),imshow(squeeze(Eext(:,round(end/2),:)),[]);
     subplot(2,3,3),imshow(squeeze(Eext(round(end/2),:,:)),[]);
     subplot(2,3,4),imshow(squeeze(Fext(:,:,round(end/2),:))+0.5);
     subplot(2,3,5),imshow(squeeze(Fext(:,round(end/2),:,:))+0.5);
     subplot(2,3,6),imshow(squeeze(Fext(round(end/2),:,:,:))+0.5);
     h=figure; set(h,'render','opengl'); hold on;
     %patch(i,'facecolor',[1 0 0],'facealpha',0.1);
     ind=find(I(:)>0);
     [ix,iy,iz]=ind2sub(size(Eext),ind);
     plot3(ix,iy,iz,'b.');
     hold on;
     h=patch(FV,'facecolor',[1 0 0],'facealpha',0.1);
     drawnow; pause(0.1);
end

% Make the interal force matrix, which constrains the moving points to a
% smooth contour
S=SnakeInternalForceMatrix3D(FV,Options.Alpha,Options.Beta,Options.Gamma);
for i=1:Options.Iterations
    FV=SnakeMoveIteration3D(S,FV,Fext,Options.Gamma,Options.Kappa,Options.Delta,Options.Lambda);

    % Show current contour
    if(Options.Verbose)
        if(ishandle(h));
            delete(h);
            h=patch(FV,'facecolor',[1 0 0],'facealpha',0.1);
            drawnow; %pause(0.1);
        end
    end
end


