function Iout=warp(Ibuffer, Ioutsizes,Mshear,Mwarp2D,c)
% This function warp,  will warp the shear rendered buffer image
%
% 	 Iout =WARP(Ibuffer,sizes,Mshear,Mwarp2D,c);
%
 
Ibuffer_sizex=size(Ibuffer,1);
Ibuffer_sizey=size(Ibuffer,2);

transx=Mwarp2D(1,3)+Mshear(1,4); 
transy=Mwarp2D(2,3)+Mshear(2,4);


P1x=[0 0 Ioutsizes(1)-1 Ioutsizes(1)-1];
P1y=[0 Ioutsizes(2)-1  0 Ioutsizes(2)-1];

for i=1:4
    px=P1x(i);
    py=P1y(i);
    pxreal=(px-Ioutsizes(1)/2); 
    pyreal=(py-Ioutsizes(2)/2);
    pxrealt=Mwarp2D(1,1)*pxreal+Mwarp2D(1,2)*pyreal+(Ibuffer_sizex)/2+transx; 
    pyrealt=Mwarp2D(2,1)*pxreal+Mwarp2D(2,2)*pyreal+(Ibuffer_sizey)/2+transy;
    P2x(i)=pxrealt;
    P2y(i)=pyrealt;
end
base_points=[P1y;P1x]'+1;
input_points=[P2y;P2x]'+1;
tform= cp2tform(input_points,base_points,'affine');
Iout = imtransform(Ibuffer,tform,'bilinear','XData',[1 Ioutsizes(1)], 'YData',[1 Ioutsizes(2)],'XYScale',1);

Iout(Iout>1)=1;
Iout(Iout<0)=0;
