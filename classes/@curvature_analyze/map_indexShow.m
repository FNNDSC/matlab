function [C, adata, a_status] = map_indexShow(C, astr_mapIndex)
%
% NAME
%
%  function [C, adata, a_status] = map_indexShow(C, astr_mapIndex)
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze  class
%       astr_mapIndex   string          map reference
%
% OPTIONAL
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
%	This method 'prints' (or 'shows') the contents of a map reference.
%       
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%       o the <astr_mapIndex> should be valud
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

C.mstack_proc   = push(C.mstack_proc, 'map_indexShow');

adata           = [];
a_status        = 0;

[adata, a_status]   = map_get(C, astr_mapIndex);
if a_status > 0
    fprintf('%40s', astr_mapIndex);
    disp(adata);
if ~numel(adata), fprintf('\n'); end
else
    return;
end

[C.mstack_proc, element] = pop(C.mstack_proc);

