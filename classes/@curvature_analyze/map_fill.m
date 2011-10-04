function [C, a_status] = map_fill(C, varargin)
%
% NAME
%
%  function [C, a_status] = map_fill(C [,<floodValue>])
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze  class
%
% OPTIONAL
%       floodValue      any             value to insert at each map reference
%
% OUTPUT
%       C               class           curvature_analyze  class
%       a_status        int             map index status. If any
%                                       keys are undefined, <a_status>
%                                       will be negative
%
% DESCRIPTION
%
%	This method fills a map structure. If a <floodValue> is specified,
%       the entire map is filled with this data element (of any type).
%       If no <floodValue> is specified, each map reference is filled
%       with an incremental count as the map is processed.
%       
%       The main purpose of this method is debugging.
%
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%
% POSTCONDITIONS
%
%       o <adata> referenced by the index.
%       o boolean <a_status>.
%       
% NOTE:
%
% HISTORY
% 25 September 2009
% o Initial design and coding.
%

C.mstack_proc 	                = push(C.mstack_proc, 'map_fill');

if length(varargin)
    [C, adata, a_status]        = map_process(C, @mapindex_valueSet, varargin{:});
else
    [C, adata, a_status]        = map_process(C, @mapindex_valueSet);
end

[C.mstack_proc, element]        = pop(C.mstack_proc);

