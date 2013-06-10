function setMyData(data,handle)
% Store data struct in figure
if(nargin<2), handle=gcf; end
setappdata(handle,'data3d',data);
