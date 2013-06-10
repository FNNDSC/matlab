function render_image = render_color(volume, axes_size, viewer_matrix,alphatable,colortable)
% Function RENDER_COLOR will volume render a Image of a 3D volume with
% transperancy and colortable.
%
% I = RENDER_MIP(V, SIZE, Mview, ALPHATABLE, COLORTABLE);
% 
% inputs,
%  V: Input image volume
%  SIZE: Sizes (height and length) of output image
%  Mview: Viewer (Transformation) matrix 4x4
%  ALPHATABLE: Mapping from intensities to transperancy 
%               range [0 1], dimensions Nx1
%  COLORTALBE: Mapping form intensities to color
%               range [0 1], dimensions Nx3
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
%   load TestVolume;
%   % Parameters
%   sizes=[400 400];
%   Mview=makeViewMatrix([45 45 0],[0.5 0.5 0.5],[0 0 0]);
%   alphatable=(0:999)/999;
%   colortable=hsv(1000);
%   % Render and show image
%   I = render_color(V, sizes, Mview,alphatable,colortable);
%   imshow(I);
%
% Function is written by D.Kroon University of Twente (October 2008)


% Calculate the shear and warp matrices
[Mshear,Mwarp2D,c]=makeShearWarpMatrix(viewer_matrix,size(volume));
Mwarp2Dinv=inv(double(Mwarp2D)); Mshearinv=inv(Mshear);

% Volume render the data to an image
switch(class(volume))
    case 'uint8'
        render_image = render_mex_vrc_uint8(volume,axes_size(1:2),Mshearinv,Mwarp2Dinv,c,alphatable,colortable);
    case 'uint16'
        render_image = render_mex_vrc_uint16(volume,axes_size(1:2),Mshearinv,Mwarp2Dinv,c,alphatable,colortable);
    case 'single'
        render_image = render_mex_vrc_single(volume,axes_size(1:2),Mshearinv,Mwarp2Dinv,c,alphatable,colortable);
    case 'double'
        render_image = render_mex_vrc_double(volume,axes_size(1:2),Mshearinv,Mwarp2Dinv,c,alphatable,colortable);
    otherwise
        error('rendermip:inputs', 'Unknown volume datatype');
end

