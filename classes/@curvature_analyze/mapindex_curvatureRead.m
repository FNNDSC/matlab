function [C, elementData, a_status] ...
    = mapindex_curvatureRead(C, astr_mapIndex, elementData)     
%
% NAME
%
%  function [C, elementData, a_status]
%       = mapindex_curvatureRead(C, astr_mapIndex, elementData)  
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
% DESCRIPTION
%
%       This method reads curvature maps from a FreeSurfer into
%       the appropriate index within the internal map data structure.
%       
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%       o the <astr_mapIndex> should be valid.
%
% POSTCONDITIONS
%
%       o <adata> referenced by the index.
%       o boolean <a_status>.
%
% NOTE:
%
% HISTORY
% 28 September 2009
% o Initial design and coding.
%

C.mstack_proc 	        = push(C.mstack_proc, 'mapindex_curvatureRead');
verbosityLevel          = C.m_verbosityLevel;
C.m_verbosityLevel      = 2;

a_status        = 0;
adata           = [];

[       str_hemi,               ...
        str_curvFunc,           ...
        str_subjName,           ...
        str_region,             ...
        str_surfaceType,        ...
        str_core,               ...
        a_status] = map_indexSplit(C, astr_mapIndex);

if strcmp(str_region, 'entire')

    str_subjDir = C.mmap_subjectInfo(str_subjName).mstr_subjName;
    str_relCurvFileName         = sprintf('%s.%s.%s.%s',        ...
                                    str_hemi,                   ...
                                    str_surfaceType,            ...
                                    str_curvFunc,               ...
                                    C.mstr_curvFilePostfix);

    %
    % The 'thickness' is a special case. Strictly speaking, it is not
    % a curvature, but the file and contents conform to the same
    % data conventions. If the str_curvFunc is 'thickness', then
    % the str_relCurvFileName is set specifically for this case.
    if strcmp(str_curvFunc, 'thickness')
        str_relCurvFileName     = [ str_hemi '.thickness'];
    end
    
    str_curvatureFileName       = sprintf('%s/%s/%s',           ...
                                    str_subjDir,                ...
                                    C.mstr_curvFSDir,           ...
                                    str_relCurvFileName);

    lprintf(C, 'Reading %s %s', str_subjDir,      ...
            str_relCurvFileName);
    [adata, fnum]       = read_curv(str_curvatureFileName);
    colprintf(C, '', '[ ok ]\n');

    if C.mb_curvaturesPostScale
        f_scale   = C.mmap_subjectInfo(str_subjName).mf_linearScaleFactor;
        if  strcmp(str_curvFunc, 'K')   |                       ...
            strcmp(str_curvFunc, 'C')   |                       ...
            strcmp(str_curvFunc, 'S')
                f_scale         = f_scale^2;
                colprintf(C, 'Scale factor', '[ surface ]\n');
        else
                colprintf(C, 'Scale factor', '[ linear ]\n');
        end
        colprintf(C, 'Applying postscale factor', '');
        adata           = adata * f_scale;
        colprintf(C, '', '[ %f ]\n', f_scale);
    end
    elementData{C.mi_indexCurvature}    = single(adata);    
end

C.m_verbosityLevel       = verbosityLevel;
[C.mstack_proc, element] = pop(C.mstack_proc);

