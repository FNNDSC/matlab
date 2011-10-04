function [C, adata, a_status] = mapindex_valueSet(C, astr_mapIndex, varargin)
%
% NAME
%
%  function [C, adata, a_status] = mapindex_valueSet(C, astr_mapIndex [, adata])
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze class
%       astr_mapIndex   string          map reference
%
% OPTIONAL
%       adata           any             data content to store in the
%                                       map reference
%
% OUTPUT
%       C               class           curvature_analyze  class
%       adata           data            data retrieved from map
%       a_status        int             map index status. If any
%                                       keys are undefined, <a_status>
%                                       will be negative
%
% DESCRIPTION
%
%	This method sets the value component of a map reference. If <adata>
%       is specified, the value is set to this value, otherwise the value
%       is an incremental count of calls to this method.
%       
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%       o the <astr_mapIndex> should be valid.
%
% POSTCONDITIONS
%
%       o <adata> referenced by the index.
%       o boolean <a_status>.
%       
% NOTE:
%
% HISTORY
% 28 September 2009
% o Initial design and coding.
%

C.mstack_proc   = push(C.mstack_proc, 'mapindex_valueSet');

persistent      calls;
if isempty(calls), calls        = 0; end;
calls           = calls + 1;

if length(varargin)
    adata       = varargin{:};
else
    adata       = calls;
end;

[C, a_status]   = map_set(C, astr_mapIndex, adata);

[C.mstack_proc, element] = pop(C.mstack_proc);

