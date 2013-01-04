function [C, elementData, a_status] ...
    = mapindex_curvatureParcellate(C, astr_mapIndex, elementData)     
%
% NAME
%
%  function [C, elementData, a_status]
%       = mapindex_curvatureParcellate(C, astr_mapIndex, elementData)     
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
%       This method is responsible for populating the relevant 'curvature'
%       core data component of <astr_mapIndex>. Initially, this is
%       parsed from the existing 'entire' curvature data and the 
%       annotation. Once parsed, this curvature data is also saved in
%       the corresponding working directory of <astr_mapIndex>.
%       
%       If, on future runs of the same parcellation, a pre-existing
%       curvature parcellation file is found, this will be read and the
%       parsing from the 'entire' curvature will be skipped.
%
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%       o the <astr_mapIndex> should be valid.
%
% POSTCONDITIONS
%
%       o <adata> is the parcellated curvature data.
%       o boolean <a_status>.
%       o While parcellating from 'entire' curvature, the parcellated
%         curvature for <astr_mapIndex> is saved to the relevant
%         working directory.
%
% NOTE:
%
% HISTORY
% 12 January 2010
% o Initial design and coding.
% 
% 14 January 2010
% o Save parcellated curvs.
%

%%%%%%%%%%%%%%
%%% Nested functions
%%%%%%%%%%%%%%

function dir_create(astr_dir)
        [ret str_console] = unix(sprintf('mkdir -p %s', astr_dir));
        if ret
            vprintf(c, 1, 'While attempting to create %s', astr_dir);
            error_exit(c, '1', 'Could not create working dir')
        end
end


%%%%%%%%%%%%%%
%%%%%%%%%%%%%%


C.mstack_proc 	        = push(C.mstack_proc, 'mapindex_curvatureParcellate');

a_status        = 0;
adata           = [];

[       str_hemi,               ...
        str_curvFunc,           ...
        str_subjName,           ...
        str_region,             ...
        str_surfaceType,        ...
        str_core,               ...
        a_status] = map_indexSplit(C, astr_mapIndex);

if ~strcmp(str_region, 'entire')
    
    
    if C.mb_regionFilter
        iregion     = find(ismember(C.mcstr_regionFilter, str_region)==1);
        if isempty(iregion), return, end;
    end
    
    verbosityLevel          = C.m_verbosityLevel;
    C.m_verbosityLevel      = 2;
   

    [C str_wd status]   = mapindex_workingDirGet(C, astr_mapIndex);
    str_parcelDir       = [ str_wd '/crv' ];
    str_parcelFileName  = [ str_parcelDir '/' astr_mapIndex '.curvature'];

    readSuccess = 1;
    try
        lprintf(C, 'Read %s...', astr_mapIndex);
        [v_curvParcel, numfaces]        = read_curv(str_parcelFileName);
        
    catch
        readSuccess = 0;
    end
    
    if ~readSuccess              
        if ~exist(str_parcelDir, 'dir'), dir_create(str_parcelDir); end;
                   
        str_subjectDir = C.mmap_subjectInfo(str_subjName).mstr_subjName;
        str_annotationFile          = sprintf('%s/%s/%s.%s',                ...
                                            str_subjectDir,                     ...
                                            C.ms_annotation.mstr_labelDir,      ...
                                            str_hemi,                           ...
                                            C.ms_annotation.mstr_annotFile);

                                        
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
                                        str_subjectDir,                ...
                                        C.mstr_curvFSDir,           ...
                                        str_relCurvFileName);


        % Read in 'entire' annotation file and curvature    

        [v_list, v_label, sAnnot]            = read_annotation(              ...
                                                    str_annotationFile, 0);

        [v_curvEntire, fnum]       = read_curv(str_curvatureFileName);
        colprintf(C, '', '[ ok ]\n');
        lprintf(C, 'Parcel %s...', astr_mapIndex);

        iregion     = find(ismember(sAnnot.struct_names, str_region)==1);
        if isempty(iregion)
            error_exit(C, '1', 'Could not find %s in annotation', str_region);
        end
        if ~C.mb_parcelFromLabelFile
            ilabel              = sAnnot.table(iregion, 5);
            v_curvParcel        = v_curvEntire(find(v_label == ilabel));
        else
            % Here, we attempt to read from the original label file
            % and not the annotation structure. This is useful in cases
            % where the annotation packed label is different from the
            % original label, which is typically the case for "overlapping"
            % border ISO regions.
            str_labelFileName   = sprintf('%s.%s',                              ...
                                            str_hemi,                           ...
                                            str_region);
            lprintf(C, '\nlabel file = %s\n', str_labelFileName);
            %keyboard;
            label               = read_label(str_subjName, str_labelFileName);
            v_indices           = label(:,1);
            % Since the label is read from a C-based counting system, we need
            % to increase each index with '1' for MatLAB...
            v_indices           = v_indices + 1;
            v_curvParcel        = v_curvEntire(v_indices);
        end
        write_curv(str_parcelFileName, v_curvParcel, -1);
    end

    adata                           = single(v_curvParcel); 
    elementData{C.mi_indexCurvature}   = adata;
    colprintf(C, '', '[ %d ]\n', numel(v_curvParcel));

    C.m_verbosityLevel              = verbosityLevel;    
    
end
[C.mstack_proc, element]        = pop(C.mstack_proc);

end
