function [avgmatrix, avgbinmatrix]=load_avg_matrix(file,param)

fid=fopen(file,'r');
filelist=fgetl(fid);
list=fgetl(fid);
while list~=-1
    filelist=strvcat(filelist,list);
    list=fgetl(fid);
end;
fclose(fid);

matfile=load(filelist(1,filelist(1,:)~=' '));
cmat=matfile.cmatrix;
avgmatrix=zeros(size(cmat,1),size(cmat,2));
avgbinmatrix=zeros(size(cmat,1),size(cmat,2));

subjnum=size(filelist,1);
for i=1:subjnum
    matfile=load(filelist(i,filelist(i,:)~=' '));
    cmat=matfile.cmatrix;
    cmatbin=cmat;
    cmatbin(cmatbin<param)=0;   cmatbin(cmatbin>0)=1;
    avgmatrix=avgmatrix+cmat;
    avgbinmatrix=avgbinmatrix+cmatbin;
end;

avgmatrix=avgmatrix/subjnum;
avgbinmatrix=avgbinmatrix/subjnum;