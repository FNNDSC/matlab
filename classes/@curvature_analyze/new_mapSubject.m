function H = new_mapSubject(C, varargin)
%
% NAME
%
%  function C = new_mapSubject(C)
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
%	This method creates a new subject data map instance. This map
%       contains maps of 'regions'.
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

C.mstack_proc 	= push(C.mstack_proc, 'new_mapSubject');

map_subj2region = containers.Map();
for subj        = 1:numel(C.mc_subjectInfo)
    str_subj                    = C.mc_subjectInfo{subj}.mstr_subjLabel;
    map_subj2region(str_subj)   = new_mapRegion(C);
end

H = map_subj2region;

[C.mstack_proc, element] = pop(C.mstack_proc);

