function [C, a_status] = map_histogramsProcess(C)
%
% NAME
%
%  function [a_status] = map_histogramsProcess(C)
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
%	This method cycles over the internal map structure and processes
%       all the embedded curvature data for histogram information.
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

C.mstack_proc 	                = push(C.mstack_proc, 'map_histogramsProcess');

[C, adata, a_status]            = map_process(C, @mapindex_histogramProcess);

[C.mstack_proc, element]        = pop(C.mstack_proc);

