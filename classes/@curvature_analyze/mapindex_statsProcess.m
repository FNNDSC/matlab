function [C, elementData, a_status] ...
    = mapindex_statsProcess(C, astr_mapIndex, elementData)     
%
%  function [C, elementData, a_status]
%       = mapindex_statsProcess(C, astr_mapIndex, elementData)     
%
% ARGUMENTS
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
%       This method calculates some simple statistical data on the node
%       curvature, storing the information in a local ms_stats structure.
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
%       o <adata> referenced by the index is the ms_stats structure for 
%         <astr_mapIndex>.
%       o boolean <a_status>.
%       o subject-specific plot jpg and eps stored in subject analysis dir.
%       o group plot stored in group analysis dir.
%       
% NOTE:
%
% HISTORY
% 15 October 2009
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

function subjStats_save(astr_outputDir, astr_outputFileStem)
    str_statsFile       = sprintf('%s/cumulative-%s.txt',               ...
                                    astr_outputDir,                     ...
                                    astr_outputFileStem);
    fid                 = fopen(str_statsFile, 'w');
    c_strFieldNames     = { 'Subj',                                     ...
                            'l', 'z', 'g',                              ...
                            'f_absav',  'f_absstd',                     ...
                            'f_av',     'f_std',                        ...
                            'f_pav',    'f_pstd',                       ...
                            'f_nav',    'f_nstd'};

    headerRow_fprintf(fid, c_strFieldNames);

    cstr_subj   = keys(map_subjStats);
    for subj = 1:numel(cstr_subj)
        str_key = cstr_subj{subj};
        s_subjInfo = C.mmap_subjectInfo(str_key);
        str_subjDir = [s_subjInfo.mstr_subjDir '/' s_subjInfo.mstr_processDir];
        str_subjFile = sprintf('%s/%s.txt', str_subjDir, astr_outputFileStem);
        fid_subj = fopen(str_subjFile, 'w');
        s_stats = map_subjStats(str_key);

        dataRow_fprintf(fid, str_key, s_stats, c_strFieldNames);
        headerRow_fprintf(fid_subj, c_strFieldNames);
        dataRow_fprintf(fid_subj, str_key, s_stats, c_strFieldNames);

        fclose(fid_subj);
    end
    fclose(fid);
end

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%


C.mstack_proc 	        = push(C.mstack_proc, 'mapindex_statsProcess');
b_saveStats             = 0;

persistent      subjIndex;
persistent      map_subjStats;
persistent      str_curvFuncPrev;
subjCount       = numel(keys(C.mmap_subjectInfo));

if isempty(subjIndex),          subjIndex       = 1;                    end;
if isempty(map_subjStats),      map_subjStats   = containers.Map();     end;


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

%str_nodeIndex       = basename(astr_mapIndex, '.curvature');
str_statsIndex      = sprintf('%s.stats', astr_mapIndex);

%if      strcmp(str_hemi,        'lh')                                        & ...
%        strcmp(str_curvFunc,    'K')                                         & ...
%        strcmp(str_region,      'intersect-frontal-parietal-r30-ply25')      & ...
%        strcmp(str_surfaceType, 'smoothwm')
%    keyboard;
%end

lprintf(C, 'Stats on %s', astr_mapIndex);
v_curv              = elementData{C.mi_indexCurvature};

b_perc              = 1;
[C.ms_stats.l C.ms_stats.z C.ms_stats.g]            = lzg(v_curv, b_perc);
[C.ms_stats.v_l C.ms_stats.v_z C.ms_stats.v_g]      = v_lzg(v_curv);
C.ms_stats.f_absav                                  = mean(abs(v_curv));
C.ms_stats.f_absstd                                 = std(abs(v_curv));
C.ms_stats.f_av                                     = mean(v_curv);
C.ms_stats.f_std                                    = std(v_curv);
C.ms_stats.f_pav                                    = mean(C.ms_stats.v_g);
C.ms_stats.f_pstd                                   = std(C.ms_stats.v_g);
C.ms_stats.f_nav                                    = mean(C.ms_stats.v_l);
C.ms_stats.f_nstd                                   = std(C.ms_stats.v_l);

adata                           = C.ms_stats;
elementData{C.mi_indexStats}    = adata;

map_subjStats(str_subjName)     = adata;

colprintf(C, '', '[ %d ]\n', subjIndex);

% Increase subject index and optionally perform the cumulative save
subjIndex           = subjIndex+1;
if mod(subjCount, subjIndex) == subjCount
    subjIndex       = 1;
    str_fileStem    = sprintf('stats-%s.%s.%s.%s',                  ...
                        str_hemi,                                   ...
                        str_curvFunc,                               ...
                        str_region,                                 ...
                        str_surfaceType);
    lprintf(C, 'Saving %s', str_fileStem);
    [C str_wd status]       = mapindex_workingDirGet(C, astr_mapIndex);
    subjStats_save(str_wd, str_fileStem);
    str_curvFuncPrev        = str_curvFunc;
    colprintf(C, '', '[ ok ]\n');
end
C.m_verbosityLevel       = verbosityLevel;


[C.mstack_proc, element] = pop(C.mstack_proc);

end
