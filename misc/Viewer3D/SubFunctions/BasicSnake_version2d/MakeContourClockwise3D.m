function FV=MakeContourClockwise3D(FV)
% This function MakeContourClockwise will make a surface clockwise 
% contour clockwise. This is done by calculating the volume inside the 
% surface, if it is negative we change the surface orientation.
%
%  FV=MakeContourClockwise2D(FV);
%
%  input/output,
%    FV : Triangulated surface description with FV.faces and FV.vertices
%
% Function is written by D.Kroon University of Twente (July 2010)

% Volume inside contour
volume=0;
for i=1:size(FV.faces,1)
    a=FV.vertices(FV.faces(i,1),:); b=FV.vertices(FV.faces(i,2),:); c=FV.vertices(FV.faces(i,3),:);

    k=cross(b,c);
    v = (a(1)*k(1)+a(2)*k(2)+a(3)*k(3))/6;
    
    volume=volume+v;
end
volume=-(volume);
 
% If the area inside  the contour is positive, change from counter-clockwise to 
% clockwise
if(volume<0), 
    FV.faces=[FV.faces(:,3) FV.faces(:,2) FV.faces(:,1)]; 
end

function c=cross(a,b)
a=a(:); b=b(:); 
c = [a(2,:).*b(3,:)-a(3,:).*b(2,:)
     a(3,:).*b(1,:)-a(1,:).*b(3,:)
     a(1,:).*b(2,:)-a(2,:).*b(1,:)];
 