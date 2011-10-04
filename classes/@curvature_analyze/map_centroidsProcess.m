function [C, a_status] = map_centroidsProcess(C)
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
%       all the embedded histogram data to calculate centroids.
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
% 21 October 2009
% o Initial design and coding.
%

C.mstack_proc 	                = push(C.mstack_proc, 'map_centroidsProcess');

[C, adata, a_status]            = map_processSubj(C, @mapindex_centroidsProcess);

[C.mstack_proc, element]        = pop(C.mstack_proc);

