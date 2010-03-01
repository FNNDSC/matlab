%Usage
%fetalbrain_extract('aaa.nii')
%fetalbrain_extract('aaa.nii', slice_selection)
%fetalbrain_extract('aaa.nii', slice_selection,margin)
%fetalbrain_extract('aaa.nii', slice_selection,margin, head_circumference)
%
% Parameter
% 1st: slice selection for region extraction, 0~1, (default: 0.5 ex: If the number of slice is 50, we will use 25th[50*0.5] slice and additionally 23, 27th) 
% 2nd: margin, default: 5
% 3rd: assumed head circumference (cm), default: 25 (GA 27 weeks) >> Fetal Head Circumference, AJR 138:649-653, 1982

function fetalbrain_extract(img, varargin)

default_param=[0.5 5 25];

for i=1: length(varargin);
    default_param(i)=varargin{i};
end;

p_slice=default_param(1);
p_margin=default_param(2);
p_hc=default_param(3);

hdr=spm_vol_nifti(img);
vol=spm_read_vols(hdr);

p_d=p_hc*10/pi;
hdr1=load_nii_hdr(img);
p_d=p_d/hdr1.dime.pixdim(2);

sizex=size(vol,1);  sizey=size(vol,2);  sizez=size(vol,3);
if int16(sizez*p_slice)-2>0 && int16(sizez*p_slice)-2<sizez;
    for j=1:3;
        [mini(j),centerx(j),centery(j)]=fetal_extract_core(vol,int16(sizez*p_slice)+(-2+2*(j-1)),p_d,[0.1 0.6]);
    end;
else
    disp('Wrong param of slice selection');
    return;
end;

[i,j]=min(mini);
edgevol=fetal_extract_core1(vol,int16(sizez/2)+(-2+2*(j-1)),p_d,[0.1 0.6]);
%% snake
f = 1 - edgevol/max(max(edgevol)); 
f0 = gaussianBlur(f,1);
[px,py] = gradient(f0);

x1=int16(centerx(j)-50);   x2=int16(centerx(j)+50);   y1=int16(centery(j)-50);   y2=int16(centery(j)+50);
snaker=[50 50];
if x1<1;
    snaker(1)=centerx(j)-1;
end;
if x2>sizex
    snaker(1)=sizex-centerx(j)-1;
end;
if y1<1
    snaker(2)=centery(j)-1;
end;
if y2>sizey;
    snaker(2)=sizey-centery(j)-1;
end;

t = 0:0.2:6.28;
y = centerx(j) + min(snaker)*cos(t);  x = centery(j) + min(snaker)*sin(t);
x=x';   y=y';   

for i=1:200
    % my param
    [x,y] = snakedeform(x,y,0.05,0,2,2,px,py,5);
end;
%%
%x1=int16(min(y))-10;   x2=int16(max(y))+10;   y1=int16(min(x))-10;   y2=int16(max(x))+10;
x1=int16(min(y))-p_margin;   x2=int16(max(y))+p_margin;   y1=int16(min(x))-p_margin;   y2=int16(max(x))+p_margin;
if x1<1;
    x1=1;
end;
if x2>sizex
    x2=sizex;
end;
if y1<1
    y1=1;
end;
if y2>sizey;
    y2=sizey;
end;
savevol=vol(x1:x2,y1:y2,:);
savehdr=hdr;
savehdr.fname=hdr.fname(1:(size(hdr.fname,2)-4));
savehdr.fname=strcat(savehdr.fname,'_sreg1.img');
savehdr.dim=[double(x2-x1+1) double(y2-y1+1) sizez];
spm_write_vol(savehdr,savevol);


%% With other parameter of canny edge 
for j=1:3;
    [mini(j),centerx(j),centery(j)]=fetal_extract_core(vol,int16(sizez*p_slice)+(-2+2*(j-1)),p_d,[0.1 0.2]);
end;

[i,j]=min(mini);
edgevol=fetal_extract_core1(vol,int16(sizez/2)+(-2+2*(j-1)),p_d,[0.1 0.2]);
%% snake
f = 1 - edgevol/max(max(edgevol)); 
f0 = gaussianBlur(f,1);
[px,py] = gradient(f0);

x1=int16(centerx(j)-50);   x2=int16(centerx(j)+50);   y1=int16(centery(j)-50);   y2=int16(centery(j)+50);
snaker=[50 50];
if x1<1;
    snaker(1)=centerx(j)-1;
end;
if x2>sizex
    snaker(1)=sizex-centerx(j)-1;
end;
if y1<1
    snaker(2)=centery(j)-1;
end;
if y2>sizey;
    snaker(2)=sizey-centery(j)-1;
end;

t = 0:0.2:6.28;
y = centerx(j) + min(snaker)*cos(t);  x = centery(j) + min(snaker)*sin(t);
x=x';   y=y';   

for i=1:200
    [x,y] = snakedeform(x,y,0.05,0,2,2,px,py,5);
end;
%%
%x1=int16(min(y))-10;   x2=int16(max(y))+10;   y1=int16(min(x))-10;   y2=int16(max(x))+10;
x1=int16(min(y))-p_margin;   x2=int16(max(y))+p_margin;   y1=int16(min(x))-p_margin;   y2=int16(max(x))+p_margin;
if x1<1;
    x1=1;
end;
if x2>sizex
    x2=sizex;
end;
if y1<1
    y1=1;
end;
if y2>sizey;
    y2=sizey;
end;
savevol=vol(x1:x2,y1:y2,:);
savehdr=hdr;
savehdr.fname=hdr.fname(1:(size(hdr.fname,2)-4));
savehdr.fname=strcat(savehdr.fname,'_sreg2.img');
savehdr.dim=[double(x2-x1+1) double(y2-y1+1) sizez];
spm_write_vol(savehdr,savevol);
