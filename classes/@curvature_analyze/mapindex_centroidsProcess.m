function [C, elementData, a_status] ...
    = mapindex_centroidsProcess(C, astr_mapIndex, elementData)     

%
% NAME
%
%  function [C, elementData, a_status]
%       = mapindex_centroidsProcess(C, astr_mapIndex, elementData)     
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
%       This method calculates centroids on the node histogram data,
%       storing the information in a local ms_centroid structure.
%              
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%       o the <astr_mapIndex> should be valid.
%       o this method should be accessed via callback from map_processSubj()
%         which has an innermost loop over subjects.
%
% POSTCONDITIONS
%
%       o <adata> referenced by the index is the ms_centroid structure for
%         <astr_mapIndex>.
%       o boolean <a_status>.
%       o subject-specific plot jpg and eps stored in subject analysis dir.
%       o group plot stored in group analysis dir.
%       
% NOTE:
%
% HISTORY
% 21 October 2009
% o Initial design and coding.
%

%%%%%%%%%%%%%%
%%% Nested functions
%%%%%%%%%%%%%%

function headerRow_fprintf(fid, c_strFieldNames)
    for header = 1:numel(c_strFieldNames)
        fprintf(fid, '%12s', c_strFieldNames{header});
    end
    fprintf(fid, '\n');
end

function dataRow_fprintf(fid, str_key, s_struct, c_strFieldNames)
    fprintf(fid, '%12s', str_key);
    for field = 2:numel(c_strFieldNames)
        fprintf(fid, '%12f', getfield(s_struct, c_strFieldNames{field}));
    end
    fprintf(fid, '\n');
end

function subjCentroid_save(astr_outputDir, astr_outputFileStem)
    str_centFile        = sprintf('%s/cumulative-%s.txt',               ...
                                    astr_outputDir,                     ...
                                    astr_outputFileStem);
    fid                 = fopen(str_centFile, 'w');
    c_strFieldNames     = { 'Subj', 'xn', 'yn', 'xp', 'yp', 'xc', 'yc', 'skewness', 'kurtosis'};


    headerRow_fprintf(fid, c_strFieldNames);

    cstr_subj   = keys(map_subjCentroid);
    for subj = 1:numel(cstr_subj)
        str_key = cstr_subj{subj};
        s_subjInfo = C.mmap_subjectInfo(str_key);
        str_subjDir = [s_subjInfo.mstr_subjDir '/' s_subjInfo.mstr_processDir];
        str_subjFile = sprintf('%s/%s.txt', str_subjDir, astr_outputFileStem);
        fid_subj = fopen(str_subjFile, 'w');
        s_centroid = map_subjCentroid(str_key);
        dataRow_fprintf(fid, str_key, s_centroid, c_strFieldNames);
        headerRow_fprintf(fid_subj, c_strFieldNames);
        dataRow_fprintf(fid_subj, str_key, s_centroid, c_strFieldNames);

        fclose(fid_subj);
    end
    fclose(fid);
end

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%


C.mstack_proc 	        = push(C.mstack_proc, 'mapindex_centroidsProcess');
b_savecentroid          = 0;

persistent      subjIndex;
persistent      map_subjCentroid;
persistent      str_curvFuncPrev;
subjCount       = numel(keys(C.mmap_subjectInfo));

if isempty(subjIndex),          subjIndex        = 1;                    end;
if isempty(map_subjCentroid),   map_subjCentroid = containers.Map();     end;


a_status        = 0;
adata           = [];

[       str_hemi,               ...
        str_curvFunc,           ...
        str_subjName,           ...
        str_region,             ...
        str_surfaceType,        ...
        str_core,               ...
        a_status] = map_indexSplit(C, astr_mapIndex);
if isempty(str_curvFuncPrev),   str_curvFuncPrev        = str_curvFunc; end;


if C.mb_regionFilter
    iregion     = find(ismember(C.mcstr_regionFilter, str_region)==1);
    if isempty(iregion), return, end;
end

verbosityLevel          = C.m_verbosityLevel;
C.m_verbosityLevel      = 2;

str_nodeIndex       = basename(astr_mapIndex, '.histogram');
str_centroidIndex   = sprintf('%s.centroid', str_nodeIndex);

lprintf(C, 'Centroids on %s', astr_mapIndex);
v_hist = elementData{C.mi_indexHistogram};

if ~isnan(v_hist)

    C.ms_centroid.xn            = NaN;
    C.ms_centroid.yn            = NaN;
    C.ms_centroid.xp            = NaN;
    C.ms_centroid.yp            = NaN;
    C.ms_centroid.xc            = NaN;
    C.ms_centroid.yc            = NaN;
    C.ms_centroid.skewness      = NaN;
    C.ms_centroid.kurtosis      = NaN;
    v_negHist                   = find(v_hist(:,1) <  0);
    v_posHist                   = find(v_hist(:,1) >= 0);
    if length(v_negHist) > 1
        v_negCentroid           = centroidND_find(v_hist(v_negHist,:));
        C.ms_centroid.xn        = v_negCentroid(1);
        C.ms_centroid.yn        = v_negCentroid(2);
    end
    if length(v_posHist) > 1
        v_posCentroid           = centroidND_find(v_hist(v_posHist,:));
        C.ms_centroid.xp        = v_posCentroid(1);
        C.ms_centroid.yp        = v_posCentroid(2);
        C.ms_centroid.skewness  = skewness(v_hist(:,2));
        C.ms_centroid.kurtosis  = kurtosis(v_hist(:,2));
    end
    v_centroid                  = centroidND_find(v_hist);
    C.ms_centroid.xc            = v_centroid(1);
    C.ms_centroid.yc            = v_centroid(2);

    adata                       = C.ms_centroid;
    elementData{C.mi_indexCentroid} = adata;

    map_subjCentroid(str_subjName) = adata;

    colprintf(C, '', '[ %d ]\n', subjIndex);

else
    adata                       = NaN;
    elementData{C.mi_indexCentroid} = adata;
    colprintf(C, '', '[ NaN ]\n', subjIndex);
end

% Increase subject index and optionally perform the cumulative save
subjIndex           = subjIndex+1;
if mod(subjCount, subjIndex) == subjCount
    subjIndex       = 1;
    str_fileStem    = sprintf('centroids-%s.%s.%s.%s',              ...
                        str_hemi,                                   ...
                        str_curvFunc,                               ...
                        str_region,                                 ...
                        str_surfaceType);
    lprintf(C, 'Saving %s', str_fileStem);
    [C str_wd status]       = mapindex_workingDirGet(C, astr_mapIndex);
    subjCentroid_save(str_wd, str_fileStem);
    str_curvFuncPrev        = str_curvFunc;
    colprintf(C, '', '[ ok ]\n');
end

C.m_verbosityLevel       = verbosityLevel;


[C.mstack_proc, element] = pop(C.mstack_proc);

end