function [C, elementData, a_status] ...
    = mapindex_annotationRead(C, astr_mapIndex, elementData)                         
%
% NAME
%
%  function [C, histogram, curv, centroid, stats, axis, annotArg, a_status]
%       = mapindex_annotationRead(C, astr_mapIndex,histogram, curv, ...
%                                centroid, stats, ...
%                                axis, annot)     
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze class
%       astr_mapIndex   string          map reference
%       elementData     cell            Cell containing element data
%                                       (indexed by C.mi_indexXXXX)
%
% OPTIONAL
%
% OUTPUT
%	C		class		curvature_analyze class
%       elementData     cell            Cell containing element data
%                                       (indexed by C.mi_indexXXXX)
%       a_status        int             map index status. If any
%                                       keys are undefined, <a_status>
%                                       will be negative
%
% DESCRIPTION
%
%       This method reads annotation files from a FreeSurfer into
%       the appropriate index within the internal map data structure.
%       
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%       o the <astr_mapIndex> should be valid.
%       o annotations are only read for the 'entire' region and the first
%         curvature function.
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

C.mstack_proc 	        = push(C.mstack_proc, 'mapindex_annotationRead');
verbosityLevel          = C.m_verbosityLevel;
C.m_verbosityLevel      = 2;

a_status                = 0;
adata                   = [];
b_verboseAnnotationRead = 0;

[       str_hemi,               ...
        str_curvFunc,           ...
        str_subjName,           ...
        str_region,             ...
        str_surfaceType,        ...
        str_core,               ...
        a_status] = map_indexSplit(C, astr_mapIndex);

if strcmp(str_region, 'entire')       ...
    && strcmp(str_curvFunc, C.mcstr_curvFunc{1})

    str_subjectDir = C.mmap_subjectInfo(str_subjName).mstr_subjName;
    str_annotationFile          = sprintf('%s/%s/%s.%s',                ...
                                    str_subjectDir,                     ...
                                    C.ms_annotation.mstr_labelDir,      ...
                                    str_hemi,                           ...
                                    C.ms_annotation.mstr_annotFile);

    if ~exist(str_annotationFile)
        error_exit(C, '1', ...
            sprintf('Could not access annotation file: %s', str_annotationFile));
    end

    [v_list, v_label, annot]            = read_annotation(              ...
                            str_annotationFile, b_verboseAnnotationRead);
    C.ms_annotation.msAnnotation        = annot;
    C.ms_annotation.mv_label            = v_label;
    C.ms_annotation.mv_list             = v_list;
    adata                               = C.ms_annotation;
    colprintf(C, astr_mapIndex, '[ ok ]\n');

    elementData{C.mi_indexAnnotation} = adata;
end

C.m_verbosityLevel       = verbosityLevel;
[C.mstack_proc, element] = pop(C.mstack_proc);

