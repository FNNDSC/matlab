function [ indices, points ] = find_six_equidistant_points( origin, verts )
%find_six_equidistant_points Given a point on a sphere, finds 
%   five other points of equal distance away.  
%
%   origin - Point on the sphere to find closest point to as origin
%   verts  - Array of vertex positions for sphere
%
%   Returns array of six indices and point locations on sphere

points = zeros(6,3);
indices = zeros(6,1);

% find vertex closest to origin
indices(1) = find_closest_vertex(verts, origin, 0);
points(1,:) = verts(indices(1),:);

% find vertex at opposite pole from origin
indices(2) = find_closest_vertex(verts, -points(1,:), 0);
points(2,:) = verts(indices(2),:);

% Radius is half the distance between these two points
radius = norm(points(2,:) - points(1,:), 2) / 2;

% Find a vertex (any on the equator) that is of distance
% sqrt(r^2 + r^2) away, which would put it on the equator
indices(3) = find_closest_vertex(verts, points(2,:), sqrt(radius^2 + radius^2));
points(3, :) = verts(indices(3), :);

% The point opposite points(3)
indices(4) = find_closest_vertex(verts, -points(3,:), 0);
points(4,:) = verts(indices(4), :);

% Now take the normal to vectors from center to points(1) and
% points(3) to get another point on the equator
normal=cross(points(1, :), points(3,:));
normal=normal ./ norm(normal);
normal=normal * radius;
indices(5) = find_closest_vertex(verts, normal, 0);
points(5,:) = verts(indices(5), :);

% The point on the opposite side of the sphere from the previous
indices(6) = find_closest_vertex(verts, -normal, 0);
points(6,:) = verts(indices(6), :);

end

