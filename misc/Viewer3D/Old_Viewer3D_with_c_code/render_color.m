function render_image = render_color(V, image_size, Mview,alphatable,colortable)
% Function RENDER_COLOR will volume render a Image of a 3D volume with
% transperancy and colortable.
%
% I = RENDER_COLOR(V, SIZE, Mview, ALPHATABLE, COLORTABLE);
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

% Split Colortable in R,G,B
if(size(colortable,2)>size(colortable,1)), colortable=colortable'; end
colortable_r=colortable(:,1); colortable_g=colortable(:,2); colortable_b=colortable(:,3);

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
            Ibuffer=updatebuffer(intensity_loc,Ibuffer,px,py,c,alphatable,colortable_r,colortable_g,colortable_b);
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
            Ibuffer=updatebuffer(intensity_loc,Ibuffer,px,py,c,alphatable,colortable_r,colortable_g,colortable_b);
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
            Ibuffer=updatebuffer(intensity_loc,Ibuffer,px,py,c,alphatable,colortable_r,colortable_g,colortable_b);
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
            Ibuffer=updatebuffer(intensity_loc,Ibuffer,px,py,c,alphatable,colortable_r,colortable_g,colortable_b);
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
            Ibuffer=updatebuffer(intensity_loc,Ibuffer,px,py,c,alphatable,colortable_r,colortable_g,colortable_b);
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
            Ibuffer=updatebuffer(intensity_loc,Ibuffer,px,py,c,alphatable,colortable_r,colortable_g,colortable_b);
        end
end

render_image = warp(Ibuffer, image_size(1:2),Mshearinv,Mwarp2Dinv,c);

function Ibuffer=updatebuffer(intensity_loc,Ibuffer,px,py,c,alphatable,colortable_r,colortable_g,colortable_b)
    % Rotate image for two main view directions
    if(c==2||c==5), intensity_loc=intensity_loc'; end
    
    % Calculate index in alpha transparency look up table
    indexAlpha=round(intensity_loc*(length(alphatable)-1))+1;
    % Calculate index in color look up table
    indexColor=round(intensity_loc*(length(colortable_r)-1))+1;
    
    % calculate current alphaimage
    alphaimage=alphatable(indexAlpha);         
    
    % Update the current pixel in the shear image buffer
    Ibuffer(px,py,1)=(1-alphaimage).*Ibuffer(px,py,1)+alphaimage.*colortable_r(indexColor);
    Ibuffer(px,py,2)=(1-alphaimage).*Ibuffer(px,py,2)+alphaimage.*colortable_g(indexColor);
    Ibuffer(px,py,3)=(1-alphaimage).*Ibuffer(px,py,3)+alphaimage.*colortable_b(indexColor);
