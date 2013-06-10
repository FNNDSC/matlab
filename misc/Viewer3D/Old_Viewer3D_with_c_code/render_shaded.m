function render_image = render_shaded(V, image_size, Mview,alphatable,colortable,LVector,VVector,shadingtype)
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
% Function is written by D.Kroon University of Twente (November 2008)

% Needed to convert intensities to range [0 1]
imax=1;
if(isa(V,'uint8')), imax=2^8-1; end
if(isa(V,'uint16')), imax=2^16-1; end
if(isa(V,'uint32')), imax=2^32-1; end

% Calculate the Shear and Warp Matrices
[Mshear,Mwarp2D,c]=makeShearWarpMatrix(Mview,size(V));
Mwarp2Dinv=inv(double(Mwarp2D)); Mshearinv=inv(Mshear);

% Store Volume sizes
Iin_sizex=size(V,1); Iin_sizey=size(V,2); Iin_sizez=size(V,3);

% Create Shear (intimidate) buffer
Ibuffer_sizex=ceil(1.7321*max(size(V))+1);
Ibuffer_sizey=Ibuffer_sizex;
Ibuffer=zeros([Ibuffer_sizex Ibuffer_sizey 3]);

% Adjust alpha table by voxel length change because of rotation
lengthcor=sqrt(1+(Mshearinv(1,3)^2+Mshearinv(2,3)^2));
alphatable= alphatable*lengthcor;

% Split Colortable in R,G,B
if(size(colortable,2)>size(colortable,1)), colortable=colortable'; end
colortable_r=colortable(:,1); colortable_g=colortable(:,2); colortable_b=colortable(:,3);

% Shading type -> Phong values
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


switch (c)
    case 1
        for z=0:(Iin_sizex-1);
            % Offset calculation
            xd=(-Ibuffer_sizex/2)+Mshearinv(1,3)*(z-Iin_sizex/2)+Iin_sizey/2;    
            yd=(-Ibuffer_sizey/2)+Mshearinv(2,3)*(z-Iin_sizex/2)+Iin_sizez/2; 
        
            xdfloor=floor(xd); ydfloor=floor(yd);

            % Linear interpolation constants (percentages)
            xCom=xd-floor(xd);  yCom=yd-floor(yd);
            perc(1)=(1-xCom) * (1-yCom); 
            perc(2)=(1-xCom) * yCom;
            perc(3)=xCom * (1-yCom); 
            perc(4)=xCom * yCom;

            %Calculate the coordinates on which a image slice starts and 
            %ends in the temporary shear image (buffer)
            pystart=-ydfloor; 
                if(pystart<0), pystart=0; end
            pyend=Iin_sizez-ydfloor; 
                if(pyend>Ibuffer_sizey), pyend=Ibuffer_sizey; end
            pxstart=-xdfloor; 
                if(pxstart<0), pxstart=0; end
            pxend=Iin_sizey-xdfloor; 
                if(pxend>Ibuffer_sizex), pxend=Ibuffer_sizex; end

            py=(pystart+1:pyend-1);
            % Determine y coordinates of pixel(s) which will be come current pixel
            yBas=py+ydfloor; 
            px=(pxstart+1:pxend-1);
            %Determine x coordinates of pixel(s) which will be come current pixel
            xBas=px+xdfloor; 
            xBas1=xBas+1;  xBas1(end)=xBas1(end)-1;
            yBas1=yBas+1;  yBas1(end)=yBas1(end)-1;

            % Get the intensities
            intensity_xyz1=double(squeeze(V(z+1,xBas, yBas)));
            intensity_xyz2=double(squeeze(V(z+1,xBas, yBas1)));
            intensity_xyz3=double(squeeze(V(z+1,xBas1, yBas)));
            intensity_xyz4=double(squeeze(V(z+1,xBas1, yBas1)));

            % Calculate the interpolated intensity
            intensity_loc=(intensity_xyz1*perc(1)+intensity_xyz2*perc(2)+intensity_xyz3*perc(3)+intensity_xyz4*perc(4))/imax; 
            
            % Update the shear image buffer
            N=returnnormal(z+1,xBas, yBas,V,Mview,c);
            Ibuffer=updatebuffer(intensity_loc,Ibuffer,px,py,c,alphatable,colortable_r,colortable_g,colortable_b,LightVector,ViewerVector,materialc,N);
        end
        
    case 2
        for z=0:(Iin_sizey-1),
            % Offset calculation
            xd=(-Ibuffer_sizex/2)+Mshearinv(1,3)*(z-Iin_sizey/2)+Iin_sizez/2;   
            yd=(-Ibuffer_sizey/2)+Mshearinv(2,3)*(z-Iin_sizey/2)+Iin_sizex/2; 
           
            xdfloor=floor(xd); ydfloor=floor(yd);

            % Linear interpolation constants (percentages)
            xCom=xd-floor(xd);  yCom=yd-floor(yd);
            perc(1)=(1-xCom) * (1-yCom); 
            perc(2)=(1-xCom) * yCom;
            perc(3)=xCom * (1-yCom); 
            perc(4)=xCom * yCom;

            %Calculate the coordinates on which a image slice starts and 
            %ends in the temporary shear image (buffer)
            pystart=-ydfloor; 
                if(pystart<0), pystart=0; end
            pyend=Iin_sizex-ydfloor; 
                if(pyend>Ibuffer_sizey), pyend=Ibuffer_sizey; end
            pxstart=-xdfloor; 
                if(pxstart<0), pxstart=0; end
            pxend=Iin_sizez-xdfloor; 
                if(pxend>Ibuffer_sizex), pxend=Ibuffer_sizex; end

            py=(pystart+1:pyend-1);
            % Determine y coordinates of pixel(s) which will be come current pixel
            yBas=py+ydfloor; 
            px=(pxstart+1:pxend-1);
            %Determine x coordinates of pixel(s) which will be come current pixel
            xBas=px+xdfloor; 
            xBas1=xBas+1;  xBas1(end)=xBas1(end)-1;
            yBas1=yBas+1;  yBas1(end)=yBas1(end)-1;

            % Get the intensities
            intensity_xyz1=double(squeeze(V(yBas, z+1,xBas)));
            intensity_xyz2=double(squeeze(V(yBas1, z+1,xBas)));
            intensity_xyz3=double(squeeze(V(yBas, z+1,xBas1)));
            intensity_xyz4=double(squeeze(V(yBas1, z+1,xBas1)));

            % Calculate the interpolated intensity
            intensity_loc=(intensity_xyz1*perc(1)+intensity_xyz2*perc(2)+intensity_xyz3*perc(3)+intensity_xyz4*perc(4))/imax; 

            % Update the shear image buffer
            N=returnnormal(yBas, z+1,xBas,V,Mview,c);
            Ibuffer=updatebuffer(intensity_loc,Ibuffer,px,py,c,alphatable,colortable_r,colortable_g,colortable_b,LightVector,ViewerVector,materialc,N);
        end
    case 3
        for z=0:(Iin_sizez-1),
            % Offset calculation
            xd=(-Ibuffer_sizex/2)+Mshearinv(1,3)*(z-Iin_sizez/2)+Iin_sizex/2;    
            yd=(-Ibuffer_sizey/2)+Mshearinv(2,3)*(z-Iin_sizez/2)+Iin_sizey/2; 
            xdfloor=floor(xd); ydfloor=floor(yd);

            % Linear interpolation constants (percentages)
            xCom=xd-floor(xd);  yCom=yd-floor(yd);
            perc(1)=(1-xCom) * (1-yCom); 
            perc(2)=(1-xCom) * yCom;
            perc(3)=xCom * (1-yCom); 
            perc(4)=xCom * yCom;

            %Calculate the coordinates on which a image slice starts and 
            %ends in the temporary shear image (buffer)
            pystart=-ydfloor; 
                if(pystart<0), pystart=0; end
            pyend=Iin_sizey-ydfloor; 
                if(pyend>Ibuffer_sizey), pyend=Ibuffer_sizey; end
            pxstart=-xdfloor; 
                if(pxstart<0), pxstart=0; end
            pxend=Iin_sizex-xdfloor; 
                if(pxend>Ibuffer_sizex), pxend=Ibuffer_sizex; end

            py=(pystart+1:pyend-1);
            % Determine y coordinates of pixel(s) which will be come current pixel
            yBas=py+ydfloor; 
            px=(pxstart+1:pxend-1);
            %Determine x coordinates of pixel(s) which will be come current pixel
            xBas=px+xdfloor; 
            xBas1=xBas+1;  xBas1(end)=xBas1(end)-1;
            yBas1=yBas+1;  yBas1(end)=yBas1(end)-1;

            % Get the intensities
            intensity_xyz1=double(V(xBas, yBas, z+1));
            intensity_xyz2=double(V(xBas, yBas1, z+1));
            intensity_xyz3=double(V(xBas1, yBas, z+1));
            intensity_xyz4=double(V(xBas1, yBas1, z+1));

            % Calculate the interpolated intensity
            intensity_loc=(intensity_xyz1*perc(1)+intensity_xyz2*perc(2)+intensity_xyz3*perc(3)+intensity_xyz4*perc(4))/imax; 

            % Update the shear image buffer
            N=returnnormal(xBas,yBas,z+1,V,Mview,c);
            Ibuffer=updatebuffer(intensity_loc,Ibuffer,px,py,c,alphatable,colortable_r,colortable_g,colortable_b,LightVector,ViewerVector,materialc,N);
        end
    case 4
        for z=(Iin_sizex-1):-1:0,
            % Offset calculation
            xd=(-Ibuffer_sizex/2)+Mshearinv(1,3)*(z-Iin_sizex/2)+Iin_sizey/2;    
            yd=(-Ibuffer_sizey/2)+Mshearinv(2,3)*(z-Iin_sizex/2)+Iin_sizez/2; 
        
            xdfloor=floor(xd); ydfloor=floor(yd);

            % Linear interpolation constants (percentages)
            xCom=xd-floor(xd);  yCom=yd-floor(yd);
            perc(1)=(1-xCom) * (1-yCom); 
            perc(2)=(1-xCom) * yCom;
            perc(3)=xCom * (1-yCom); 
            perc(4)=xCom * yCom;

            %Calculate the coordinates on which a image slice starts and 
            %ends in the temporary shear image (buffer)
            pystart=-ydfloor; 
                if(pystart<0), pystart=0; end
            pyend=Iin_sizez-ydfloor; 
                if(pyend>Ibuffer_sizey), pyend=Ibuffer_sizey; end
            pxstart=-xdfloor; 
                if(pxstart<0), pxstart=0; end
            pxend=Iin_sizey-xdfloor; 
                if(pxend>Ibuffer_sizex), pxend=Ibuffer_sizex; end

            py=(pystart+1:pyend-1);
            % Determine y coordinates of pixel(s) which will be come current pixel
            yBas=py+ydfloor; 
            px=(pxstart+1:pxend-1);
            %Determine x coordinates of pixel(s) which will be come current pixel
            xBas=px+xdfloor; 
            xBas1=xBas+1;  xBas1(end)=xBas1(end)-1;
            yBas1=yBas+1;  yBas1(end)=yBas1(end)-1;

            % Get the intensities
            intensity_xyz1=double(squeeze(V(z+1,xBas, yBas)));
            intensity_xyz2=double(squeeze(V(z+1,xBas, yBas1)));
            intensity_xyz3=double(squeeze(V(z+1,xBas1, yBas)));
            intensity_xyz4=double(squeeze(V(z+1,xBas1, yBas1)));

            % Calculate the interpolated intensity
            intensity_loc=(intensity_xyz1*perc(1)+intensity_xyz2*perc(2)+intensity_xyz3*perc(3)+intensity_xyz4*perc(4))/imax; 
            
            % Update the shear image buffer
            N=returnnormal(z+1,xBas,yBas,V,Mview,c);
            Ibuffer=updatebuffer(intensity_loc,Ibuffer,px,py,c,alphatable,colortable_r,colortable_g,colortable_b,LightVector,ViewerVector,materialc,N);
        end
    case 5
        for z=(Iin_sizey-1):-1:0,
            % Offset calculation
            xd=(-Ibuffer_sizex/2)+Mshearinv(1,3)*(z-Iin_sizey/2)+Iin_sizez/2;   
            yd=(-Ibuffer_sizey/2)+Mshearinv(2,3)*(z-Iin_sizey/2)+Iin_sizex/2; 
           
            xdfloor=floor(xd); ydfloor=floor(yd);

            % Linear interpolation constants (percentages)
            xCom=xd-floor(xd);  yCom=yd-floor(yd);
            perc(1)=(1-xCom) * (1-yCom); 
            perc(2)=(1-xCom) * yCom;
            perc(3)=xCom * (1-yCom); 
            perc(4)=xCom * yCom;

            %Calculate the coordinates on which a image slice starts and 
            %ends in the temporary shear image (buffer)
            pystart=-ydfloor; 
                if(pystart<0), pystart=0; end
            pyend=Iin_sizex-ydfloor; 
                if(pyend>Ibuffer_sizey), pyend=Ibuffer_sizey; end
            pxstart=-xdfloor; 
                if(pxstart<0), pxstart=0; end
            pxend=Iin_sizez-xdfloor; 
                if(pxend>Ibuffer_sizex), pxend=Ibuffer_sizex; end

            py=(pystart+1:pyend-1);
            % Determine y coordinates of pixel(s) which will be come current pixel
            yBas=py+ydfloor; 
            px=(pxstart+1:pxend-1);
            %Determine x coordinates of pixel(s) which will be come current pixel
            xBas=px+xdfloor; 
            xBas1=xBas+1;  xBas1(end)=xBas1(end)-1;
            yBas1=yBas+1;  yBas1(end)=yBas1(end)-1;

            % Get the intensities
            intensity_xyz1=double(squeeze(V(yBas, z+1,xBas)));
            intensity_xyz2=double(squeeze(V(yBas1, z+1,xBas)));
            intensity_xyz3=double(squeeze(V(yBas, z+1,xBas1)));
            intensity_xyz4=double(squeeze(V(yBas1, z+1,xBas1)));

            % Calculate the interpolated intensity
            intensity_loc=(intensity_xyz1*perc(1)+intensity_xyz2*perc(2)+intensity_xyz3*perc(3)+intensity_xyz4*perc(4))/imax; 

            % Update the shear image buffer
            N=returnnormal(yBas,z+1,xBas,V,Mview,c);
            Ibuffer=updatebuffer(intensity_loc,Ibuffer,px,py,c,alphatable,colortable_r,colortable_g,colortable_b,LightVector,ViewerVector,materialc,N);
        end
    case 6
        for z=(Iin_sizez-1):-1:0,
            % Offset calculation
            xd=(-Ibuffer_sizex/2)+Mshearinv(1,3)*(z-Iin_sizez/2)+Iin_sizex/2;    
            yd=(-Ibuffer_sizey/2)+Mshearinv(2,3)*(z-Iin_sizez/2)+Iin_sizey/2; 
            xdfloor=floor(xd); ydfloor=floor(yd);

            % Linear interpolation constants (percentages)
            xCom=xd-floor(xd);  yCom=yd-floor(yd);
            perc(1)=(1-xCom) * (1-yCom); 
            perc(2)=(1-xCom) * yCom;
            perc(3)=xCom * (1-yCom); 
            perc(4)=xCom * yCom;

            %Calculate the coordinates on which a image slice starts and 
            %ends in the temporary shear image (buffer)
            pystart=-ydfloor; 
                if(pystart<0), pystart=0; end
            pyend=Iin_sizey-ydfloor; 
                if(pyend>Ibuffer_sizey), pyend=Ibuffer_sizey; end
            pxstart=-xdfloor; 
                if(pxstart<0), pxstart=0; end
            pxend=Iin_sizex-xdfloor; 
                if(pxend>Ibuffer_sizex), pxend=Ibuffer_sizex; end

            py=(pystart+1:pyend-1);
            % Determine y coordinates of pixel(s) which will be come current pixel
            yBas=py+ydfloor; 
            px=(pxstart+1:pxend-1);
            %Determine x coordinates of pixel(s) which will be come current pixel
            xBas=px+xdfloor; 
            xBas1=xBas+1;  xBas1(end)=xBas1(end)-1;
            yBas1=yBas+1;  yBas1(end)=yBas1(end)-1;

            % Get the intensities
            intensity_xyz1=double(V(xBas, yBas, z+1));
            intensity_xyz2=double(V(xBas, yBas1, z+1));
            intensity_xyz3=double(V(xBas1, yBas, z+1));
            intensity_xyz4=double(V(xBas1, yBas1, z+1));

            % Calculate the interpolated intensity
            intensity_loc=(intensity_xyz1*perc(1)+intensity_xyz2*perc(2)+intensity_xyz3*perc(3)+intensity_xyz4*perc(4))/imax; 

            % Update the shear image buffer
            N=returnnormal(xBas,yBas,z+1,V,Mview,c);
            Ibuffer=updatebuffer(intensity_loc,Ibuffer,px,py,c,alphatable,colortable_r,colortable_g,colortable_b,LightVector,ViewerVector,materialc,N);
        end
end

render_image = warp(Ibuffer, image_size(1:2),Mshearinv,Mwarp2Dinv,c);

function N=returnnormal(x,y,z,V,Mview,c)
x1=x; y1=y; z1=z;

x2=x1+1; 
check=x2>size(V,1);
if(nnz(check)>0)
    x1(check)=x1-1; 
    x2(x2>size(V,1))=size(V,1);
end

y2=y1+1;
check=y2>size(V,2);
if(nnz(check)>0)
    y1(check)=y1-1; 
    y2(check)=size(V,2);
end

z2=z1+1;
check=z2>size(V,3);
if(nnz(check)>0)
    z1(check)=z1-1; 
    z2(check)=size(V,3);
end

S(:,:,1)=squeeze(V(x2,y1,z1)-V(x1,y1,z1));
S(:,:,2)=squeeze(V(x1,y2,z1)-V(x1,y1,z1));
S(:,:,3)=squeeze(V(x1,y1,z2)-V(x1,y1,z1));

if(c==2||c==5), 
         S2=zeros([size(S,2) size(S,1) 3]);
         S2(:,:,1)=S(:,:,1)'; S2(:,:,2)=S(:,:,2)'; S2(:,:,3)=S(:,:,3)'; S=S2;
end

N=zeros(size(S));
% Rotate the gradient and normalize to get the surface normal in direction of the viewer
N(:,:,1)=Mview(1,1)*S(:,:,1)+Mview(1,2)*S(:,:,2)+Mview(1,3)*S(:,:,3);
N(:,:,2)=Mview(2,1)*S(:,:,1)+Mview(2,2)*S(:,:,2)+Mview(2,3)*S(:,:,3);
N(:,:,3)=Mview(3,1)*S(:,:,1)+Mview(3,2)*S(:,:,2)+Mview(3,3)*S(:,:,3);

nlength=sqrt(N(:,:,1).^2+N(:,:,2).^2+N(:,:,3).^2)+0.000001;
N(:,:,1)=N(:,:,1)./nlength; 
N(:,:,2)=N(:,:,2)./nlength;
N(:,:,3)=N(:,:,3)./nlength;


function Ibuffer=updatebuffer(intensity_loc,Ibuffer,px,py,c,alphatable,colortable_r,colortable_g,colortable_b,L,V,material,N)
    % Rotate image for two main view directions
    if(c==2||c==5),  intensity_loc=intensity_loc'; end
    
    % Calculate index in alpha transparency look up table
    indexAlpha=round(intensity_loc*(length(alphatable)-1))+1;
    % Calculate index in color look up table
    indexColor=round(intensity_loc*(length(colortable_r)-1))+1;

    Ia=1;

    % Id = dot(N,L);
    Id=N(:,:,1)*L(1)+N(:,:,2)*L(2)+N(:,:,3)*L(3);
    
    % R = 2.0*dot(N,L)*N - L;
    R(:,:,1)=2*Id.*N(:,:,1)-L(1); 
    R(:,:,2)=2*Id.*N(:,:,2)-L(2); 
    R(:,:,3)=2*Id.*N(:,:,3)-L(3);
    
    %Is = max(pow(dot(R,V),3),0);
    Is=R(:,:,1)*V(1)+R(:,:,2)*V(2)+R(:,:,3)*V(3); 
    
    Is(Is<0)=0;
    % Specular exponent
    Is=Is.^material(4);
   
    % Phong shading values
    Ipar=zeros([size(Id) 3]);
    Ipar(:,:,1)=material(1)*Ia; 
    Ipar(:,:,2)=material(2)*Id; 
    Ipar(:,:,3)=material(3)*Is;
    
    % calculate current alphaimage
    alphaimage=alphatable(indexAlpha);         

    % Update the current pixel in the shear image buffer
    Ibuffer(px,py,1)=(1-alphaimage).*Ibuffer(px,py,1)+alphaimage.*(colortable_r(indexColor).*(Ipar(:,:,1)+Ipar(:,:,2))+Ipar(:,:,3));
    Ibuffer(px,py,2)=(1-alphaimage).*Ibuffer(px,py,2)+alphaimage.*(colortable_g(indexColor).*(Ipar(:,:,1)+Ipar(:,:,2))+Ipar(:,:,3));
    Ibuffer(px,py,3)=(1-alphaimage).*Ibuffer(px,py,3)+alphaimage.*(colortable_b(indexColor).*(Ipar(:,:,1)+Ipar(:,:,2))+Ipar(:,:,3));

    
    
    
