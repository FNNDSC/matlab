function H = new_mapHemi(C, varargin)
%
% NAME
%
%  function C = new_mapHemi(C)
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze  class
%
% OPTIONAL
%
% OUTPUT
%	H		handle          a handle to the created subject
%                                       map.
%	
% DESCRIPTION
%
%	This method creates a new subject brain hemi map instance. This map
%       contains maps of 'curvFuncs'. It is the top level map data structure.
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

C.mstack_proc 	= push(C.mstack_proc, 'new_mapHemi');

map_hemi2curv   = containers.Map();
for hemi        = 1:numel(C.mcstr_brainHemi);
    str_hemi                    = C.mcstr_brainHemi{hemi};
    map_hemi2curv(str_hemi)     = new_mapCurvFunc(C);
end

H = map_hemi2curv;

[C.mstack_proc, element] = pop(C.mstack_proc);

