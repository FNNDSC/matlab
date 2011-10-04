function [C, a_status] = map_centoidsPlot(C)
%
% NAME
%
%  function [a_status] = map_centroidsPlot(C)
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
%       all the embedded centroid data and generates cumulative centroid
%       plots.
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
% 14 October 2009
% o Initial design and coding.
%

C.mstack_proc 	                = push(C.mstack_proc, 'map_centroidsPlot');

[C, adata, a_status]            = map_processSubj(C, @mapindex_centroidsPlot);

[C.mstack_proc, element]        = pop(C.mstack_proc);

