function [a_status] = map_show(C)
%
% NAME
%
%  function [a_status] = map_show(C)
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze  class
%
% OPTIONAL
%
% OUTPUT
%       a_status        int             map index status. If any
%                                       keys are undefined, <a_status>
%                                       will be negative
%
% DESCRIPTION
%
%	This method 'prints' (or 'shows') the contents of the core map
%       data structure defined in the class. The class access is abstracted
%       in the map_process() method.
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

C.mstack_proc 	                = push(C.mstack_proc, 'map_show');

[C, adata, a_status]            = map_process(C, @mapindex_valueShow);

[C.mstack_proc, element]        = pop(C.mstack_proc);

