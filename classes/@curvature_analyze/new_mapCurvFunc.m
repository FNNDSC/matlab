function H = new_mapCurvFunc(C, varargin)
%
% NAME
%
%  function C = new_mapCurvFunc(C)
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze  class
%
% OPTIONAL
%
% OUTPUT
%	H		handle          a handle to the created curvature func
%                                       map.
%
% DESCRIPTION
%
%	This method creates a new curvature func data map instance. This map
%       contains maps of 'subjects'. 
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

C.mstack_proc 	= push(C.mstack_proc, 'new_mapCurvFunc');

map_curv2subj   = containers.Map();
for curvFunc    = 1:numel(C.mcstr_curvFunc)
    str_curvFunc                = C.mcstr_curvFunc{curvFunc};
    map_curv2subj(str_curvFunc) = new_mapSubject(C);
end

H = map_curv2subj;

[C.mstack_proc, element] = pop(C.mstack_proc);

