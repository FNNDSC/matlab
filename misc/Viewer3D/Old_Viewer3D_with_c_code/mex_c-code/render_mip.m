function render_image = render_mip(volume, image_size, Mview)
% Function RENDER_MIP will render a Maximum Intensity Image of a 3D volume
%
% I = RENDER_MIP(V, SIZE, Mview);
% 
% inputs,
%  V: Input image volume
%  SIZE: Sizes (height and length) of output image
%  Mview: Viewer (Transformation) matrix 4x4
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
%   % Render and show image
%   I = render_mip(V, sizes, Mview);
%   imshow(I);
%
% Function is written by D.Kroon University of Twente (October 2008)

% Calculate the shear and warp matrices
[Mshear,Mwarp2D,c]=makeShearWarpMatrix(Mview,size(volume));
Mwarp2Dinv=inv(double(Mwarp2D)); Mshearinv=inv(Mshear);

% Volume render the data to an image
switch(class(volume))
    case 'uint8'
        render_image = render_mex_mip_uint8(volume, image_size(1:2),Mshearinv,Mwarp2Dinv,c);
    case 'uint16'
        render_image = render_mex_mip_uint16(volume, image_size(1:2),Mshearinv,Mwarp2Dinv,c);
    case 'single'
        render_image = render_mex_mip_single(volume, image_size(1:2),Mshearinv,Mwarp2Dinv,c);
    case 'double'
        render_image = render_mex_mip_double(volume, image_size(1:2),Mshearinv,Mwarp2Dinv,c);
    otherwise
        error('rendermip:inputs', 'Unknown volume datatype');
end

