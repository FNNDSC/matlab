function [C, a_status] = map_annotationsRead(C)
%
% NAME
%
%  function [a_status] = map_annotationsRead(C)
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze class
%
% OPTIONAL
%
% OUTPUT
%       C               class           curvature_analyze class
%       a_status        int             map index status. If any
%                                       processing error has occured,
%                                       <a_status> will be negative.
%
% DESCRIPTION
%
%	This method cycles over the internal map structure and reads all the
%       relevant annotation files.
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
% 11 January 2010
% o Initial design and coding.
%

C.mstack_proc 	                = push(C.mstack_proc, 'map_annotationsRead');

[C, adata, a_status]            = map_process(C, @mapindex_annotationRead);

[C.mstack_proc, element]        = pop(C.mstack_proc);

