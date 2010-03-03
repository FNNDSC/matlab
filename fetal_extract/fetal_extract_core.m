function [mini,centerx,centery]=corework(vol,slicenum,diameter,cannythres)
%dddddd

ims=vol(:,:,slicenum);
imscan=edge(ims,'canny',cannythres);
imscanlabel=bwlabel(imscan,8);
im=imscanlabel;

labelnum=max(max(im));
labelsize=zeros(1,labelnum);
for i=1:labelnum;
    a=find(im==i);
    labelsize(i)=size(a,1);
end;
maxcomp=max(labelsize);

value=zeros(labelnum,maxcomp,2);
for i=1:labelnum;
    [value(i,1:labelsize(i),1),value(i,1:labelsize(i),2)]=find(im==i);
end;

r=round(diameter/2);
[xx,yy]=ndgrid(-r:r);
se=sqrt(xx.^2+yy.^2)<=r;   se=double(se);
secan=edge(se,'canny');
[selex,seley]=find(secan==1);
selex=selex-r-1; seley=seley-r-1;

distmap=zeros(1,labelnum);
for i=1:labelnum;
    a=zeros(labelsize(i),2);
    a(:,:)=value(i,1:labelsize(i),:);
    centerx=mean(a(:,1));   centery=mean(a(:,2));
    compare(:,1)=selex+centerx; compare(:,2)=seley+centery;
    dmat=dist(a,compare');
    min1=min(dmat); min2=min(dmat');
    distmap(i)=(mean(min1)+mean(min2))/2;
end;
[j,i]=min(distmap);


a=zeros(labelsize(i),2);
a(:,:)=value(i,1:labelsize(i),:);
centerx=mean(a(:,1));   centery=mean(a(:,2));
mini=j;
