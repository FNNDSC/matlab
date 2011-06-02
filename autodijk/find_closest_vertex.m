function [minIndex, minDist] = find_closest_vertex(vertices, pos, dist)
%
%   [minIndex, minDist] = find_closest_vertex(vertices, faces, pos)
%
%   vertices - Nx3 array of double vertex positions
%   pos      - 3x1 double of position to find closest to
%   dist     - Distance between pos and vert to try to find (0 means
%   closest)
%
%   Returns the vertex index (minIndex) of the closest vertex along with 
%   the distance (minDist)
%
%  Example:
%
%   [vc1,faces1] = read_surf('/chb/users/ginsburg/projects/curvatureAnalysis/recon-normal/registered-to-CHB01/CHB02/surf/lh.sphere.reg');
%   [vc2,faces2] = read_surf('/chb/users/ginsburg/projects/curvatureAnalysis/recon-normal/registered-to-CHB01/CHB03/surf/lh.sphere.reg');
%   [index1, dist1] = find_closest_vertex(vc1, [0, 0, 100]);
%   [index2, dist2] = find_closest_vertex(vc2, vc1(index1,:));
%
%   Now index1 and index2 point to the vertex in each respective surface
%   with the vertex closest to position [0, 0, 100]
curMinDist = 2^32;
minIndex = -1;
for vert=1:length(vertices)
   curVert=vertices(vert,:);
   curDist=norm(curVert - pos, 2);
   if (abs(curDist - dist) < curMinDist)
       minIndex = vert;
       curMinDist = abs(curDist - dist);
       minDist = curDist;
   end
end


