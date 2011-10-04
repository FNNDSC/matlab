function H = new_mapRegion(C, varargin)
%
% NAME
%
%  function C = new_mapRegion(C)
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze  class
%
% OPTIONAL
%
% OUTPUT
%	H		handle          a handle to the created region
%                                       map.
%	
% DESCRIPTION
%
%	This method creates a new region data map instance. This map
%       contains maps of 'surfaceType'.
%       
%       See the map_process() method for a description of the map branch
%       hierarchy.
%
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%
% POSTCONDITIONS
%
%       o a handle to the created map is returned.
%
% NOTE:
%
% HISTORY
% 25 September 2009
% o Initial design and coding.
%

C.mstack_proc 	= push(C.mstack_proc, 'new_mapRegion');

map_region2surfaceType = containers.Map();
for region      = 1:numel(C.mcstr_brainRegion)
    str_region                          = C.mcstr_brainRegion{region};
    map_region2surfaceType(str_region)  = new_mapSurfaceType(C);
end

H = map_region2surfaceType;

[C.mstack_proc, element] = pop(C.mstack_proc);

