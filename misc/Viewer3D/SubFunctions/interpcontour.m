function [x,y,z]=interpcontour(x,y,z,s)
% [x,y,z]=interpcontour(x,y,z,s)
%

pos=[x(:) y(:) z(:)];
[t,ind]=unique(pos,'rows');
pos=pos(sort(ind),:);
x=pos(:,1); y=pos(:,2); z=pos(:,3);

[x,y,z]=interpcontour1(x,y,z,1);
[x,y,z]=interpcontour1(x,y,z,s);

function [x,y,z]=interpcontour1(x,y,z,s)
i1=(length(x)+1); 
i2=(length(x)*2)+1;
x=[x(:);x(:);x(:)]; 
y=[y(:);y(:);y(:)];
z=[z(:);z(:);z(:)];

dx=x(2:end)-x(1:end-1);
dy=y(2:end)-y(1:end-1);
dz=z(2:end)-z(1:end-1);

d=cumsum([0;sqrt(dx.^2+dy.^2+dz.^2)]);
n=ceil((d(i2)-d(i1))/s);
di=linspace(d(i1),d(i2),n+1); di=di(1:end-1);

x = interp1(d,x,di,'spline');
y = interp1(d,y,di,'spline');
z = interp1(d,z,di,'spline');
