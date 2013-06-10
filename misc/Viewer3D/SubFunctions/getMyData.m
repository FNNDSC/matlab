function data=getMyData(handle)
% Get data struct stored in figure
if(nargin<1), handle=gcf; end
data=getappdata(handle,'data3d');