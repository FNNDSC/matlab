function render_image = render_shaded(volume, axes_size, viewer_matrix,alphatable,colortable,LVector,VVector,shadingtype)
% Function RENDER_SHADED will volume render a shaded Image of a 3D volume,
% with transperancy and colortable.
%
% I = RENDER_SHADED(V, SIZE, Mview, ALPHATABLE, COLORTABLE,LightVector,ViewerVector,SHADINGMATERIAL);
% 
% inputs,
%  V: Input image volume
%  SIZE: Sizes (height and length) of output image
%  Mview: Viewer (Transformation) matrix 4x4
%  ALPHATABLE: Mapping from intensities to transperancy 
%               range [0 1], dimensions Nx1
%  COLORTALBE: Mapping form intensities to color
%               range [0 1], dimensions Nx3
%  LightVector: Light direction 
%  ViewerVector: Viewer direction
%  SHADINGMATERIAL: 'shiny' or 'dull' or 'metal', set the 
%                       object shading look
%                       
% outputs,
%  I: The maximum intensity output image
%
% Volume Data, 
%  Range of V must be [0 1] in case of double or single otherwise 
%  mex function will crash. Data of type double has short render times,
%  uint16 the longest.
%
% example,
%   % Load data
%   load TestVolume2;
%   % Output image size
%   sizes=[400 400];
%   % color and alpha table
%   alphatable=[0 0 0 0 0 1 1 1 1 1];
%   colortable=[1 0 0;1 0 0;1 0 0;1 0 0;1 0 0;1 0 0;1 0 0]; 
%   % Viewer and Light direction
%   Vd = [0 0 1];
%   Ld = [0.67 0.33 0.67];
%   % Viewer Matrix
%   Mview=makeViewMatrix([0 0 0],[0.5 0.5 0.5],[0 0 0]);
%   % Render and show image
%   figure,
%   I = render_shaded(V, sizes, Mview,alphatable,colortable,Ld,Vd,'shiny');
%   imshow(I);
%
% Function is written by D.Kroon University of Twente (October 2008)

switch lower(shadingtype)
    case {'shiny'}
        materialc=[0.7,	0.6, 0.9, 20];
    case {'dull'}
        materialc=[0.7,	0.8, 0.0, 10];
    case {'metal'}
        materialc=[0.7,	0.3, 1.0, 25];
    otherwise
        materialc=[0.7,	0.6, 0.9, 20];
end

% Normalize Light and Viewer vectors
LightVector=[LVector(:);0]; LightVector=LightVector./sqrt(sum(LightVector(1:3).^2));
ViewerVector=[VVector(:);0]; ViewerVector=ViewerVector./sqrt(sum(ViewerVector(1:3).^2));

% Calculate the shear and warp matrices
[Mshear,Mwarp2D,c]=makeShearWarpMatrix(viewer_matrix,size(volume));
Mwarp2Dinv=inv(double(Mwarp2D)); Mshearinv=inv(Mshear);

% Volume render the data to an image
switch(class(volume))
    case 'uint8'
        render_image = render_mex_vrs_uint8(volume,axes_size(1:2),Mshearinv,Mwarp2Dinv,c,alphatable,colortable,LightVector,ViewerVector,viewer_matrix,materialc);
    case 'uint16'
        render_image = render_mex_vrs_uint16(volume,axes_size(1:2),Mshearinv,Mwarp2Dinv,c,alphatable,colortable,LightVector,ViewerVector,viewer_matrix,materialc);
    case 'single'
        render_image = render_mex_vrs_single(volume,axes_size(1:2),Mshearinv,Mwarp2Dinv,c,alphatable,colortable,LightVector,ViewerVector,viewer_matrix,materialc);
    case 'double'
        render_image = render_mex_vrs_double(volume,axes_size(1:2),Mshearinv,Mwarp2Dinv,c,alphatable,colortable,LightVector,ViewerVector,viewer_matrix,materialc);
    otherwise
        error('rendermip:inputs', 'Unknown volume datatype');
end



