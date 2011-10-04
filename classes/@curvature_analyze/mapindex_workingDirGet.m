function [C, adata, a_status] = mapindex_workingDirGet(C, astr_mapIndex)
%
% NAME
%
%  function [C, adata, a_status] = mapindex_workingDirGet(C, astr_mapIndex)
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze class
%       astr_mapIndex   string          map reference
%
% OPTIONAL
%
% OUTPUT
%	C		class		curvature_analyze class
%       adata           data            data retrieved from map
%       a_status        int             map index status. If any
%                                       keys are undefined, <a_status>
%                                       will be negative
%
% DESCRIPTION
%
%       This method simply returns in <adata> the current working directory
%       for any file I/O, dependent upon the <astr_mapIndex>.
%                     
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%       o the <astr_mapIndex> should be valid.
%
% POSTCONDITIONS
%
%       o <adata> is the working directory associated with any file I/O for
%         <astr_mapIndex>.
%       o boolean <a_status>.
%       
% NOTE:
%
% HISTORY
% 11 January 2010
% o Initial design and coding.
%

a_status                = 1;
C.mstack_proc 	        = push(C.mstack_proc, 'mapindex_workingDirGet');

[       str_hemi,               ...
        str_curvFunc,           ...
        str_subjName,           ...
        str_region,             ...
        str_surfaceType,        ...
        str_core,               ...
        a_status] = map_indexSplit(C, astr_mapIndex);

adata                   = [ C.mstr_analysisPath '/'             ...
                            C.ms_annotation.mstr_annotFile '/'  ...
                            str_region ];

[C.mstack_proc, element] = pop(C.mstack_proc);
