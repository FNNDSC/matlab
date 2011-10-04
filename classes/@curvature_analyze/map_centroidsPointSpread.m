function [C, a_status] = map_centoidsPointSpread(C)
%
% NAME
%
%  function [a_status] = map_centroidsPointSpread(C)
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
%       all the embedded centroid data for additional data.
%       
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%       o map_centroidsProcess()
%
% POSTCONDITIONS
%
%       o <adata> referenced by the index.
%       o boolean <a_status>.
%       
% NOTE:
%
% HISTORY
% 21 January 2010
% o Initial design and coding.
%

C.mstack_proc 	                = push(C.mstack_proc, 'map_centroidsPointSpread');

[C, adata, a_status]            = map_processSubj(C, @mapindex_centroidsPointSpread);

[C.mstack_proc, element]        = pop(C.mstack_proc);

