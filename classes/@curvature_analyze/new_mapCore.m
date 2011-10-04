function H = new_mapCore(C, varargin)
%
% NAME
%
%  function C = new_mapCore(C, [av_histogramInit, av_curvatureInit])
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze  class
%
% OPTIONAL
%
% OUTPUT
%	H		handle          a handle to the created core
%                                       map.
%
% DESCRIPTION
%
%	This method creates a new core data map instance. The core
%       map contains the actual data components of the pipeline.
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

C.mstack_proc 	= push(C.mstack_proc, 'new_mapCore');

map_core        = containers.Map();
for core        = 1:numel(C.mcstr_coreData)
    str_core            = C.mcstr_coreData{core};
    map_core(str_core)  = [];
end

H = map_core;

[C.mstack_proc, element] = pop(C.mstack_proc);

