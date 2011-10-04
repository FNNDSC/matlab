function H = new_mapSurfaceType(C, varargin)
%
% NAME
%
%  function C = new_mapSurfaceType(C)
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze class
%
% OPTIONAL
%
% OUTPUT
%	H		handle          a handle to the created surface type
%                                       map.
%	
% DESCRIPTION
%
%	This method creates a new surface-type data map instance. This map
%       contains maps of 'coreData'.
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
% 28 September 2009
% o Initial design and coding.
%

C.mstack_proc 	= push(C.mstack_proc, 'new_mapSurfaceType');

map_surfaceType2core    = containers.Map();
for surfaceType         = 1:numel(C.mcstr_surfaceType)
    str_surfaceType     = C.mcstr_surfaceType{surfaceType};
    map_surfaceType2core(str_surfaceType) = new_mapCore(C);
end

H = map_surfaceType2core;

[C.mstack_proc, element] = pop(C.mstack_proc);

