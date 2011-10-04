function C = internals_build(C, varargin)
%
% NAME
%
%  function C = internals_build(C)
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze class
%
% OPTIONAL
%
% OUTPUT
%	C		class		curvature_analyze class
%	
%
% DESCRIPTION
%
%       This function creates the core internal data 'dictionary'-type
%       structure that houses all the curvature and processed data for
%       the pipeline.
%
%       The internal map is built according to:
%
%               <hemi>.<curvFunc>.<subj>.<region>.<data>
%
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%
% POSTCONDITIONS
%
%	o the <C.mmap_data> map container is constructed.
%       o this map is not populated by this method!
%
% NOTE:
%
% HISTORY
% 24 September 2009
% o Initial design and coding.
%

C.mstack_proc 	= push(C.mstack_proc, 'internals_build');

% Determine the number of items to process
C.arr_processCount  =   numel(C.mcstr_brainHemi)        * ...
                        numel(C.mcstr_curvFunc)         * ...
                        numel(C.mc_subjectInfo)         * ...
                        numel(C.mcstr_brainRegion)      * ...
                        numel(C.mcstr_surfaceType); 

% Create global cells to store data -- the 'core' data componets
% of the old map structure...
global g_arr_data;
g_arr_data = cell(C.arr_processCount, 1);
for i = 1:C.arr_processCount
    g_arrData{i} = cell(C.mi_indexCount, 1);
end

C.arr_process           = cell(C.arr_processCount, 1);
C.arr_processSubjIndex  = zeros(C.arr_processCount, 1);


% Moved from map_process.m for efficiency.  Create the list of all items
% to process
str_hemi        = '';
str_curvFunc    = '';
str_subjName    = '';
str_region      = '';
str_surfaceType = '';
str_core        = '';
process_count   = 0;
for hemi=1:numel(C.mcstr_brainHemi)
    str_hemi    = C.mcstr_brainHemi{hemi};
    for curvFunc=1:numel(C.mcstr_curvFunc)
        str_curvFunc            = C.mcstr_curvFunc{curvFunc};
        for subj=1:numel(C.mc_subjectInfo)
            str_subjName        = C.mc_subjectInfo{subj}.mstr_subjLabel;
            for region=1:numel(C.mcstr_brainRegion)
                str_region      = C.mcstr_brainRegion{region};
                for surfaceType = 1:numel(C.mcstr_surfaceType)
                    str_surfaceType = C.mcstr_surfaceType{surfaceType};
                    str_index = sprintf('%s.%s.%s.%s.%s',        ...
                                        str_hemi,                       ...
                                        str_curvFunc,                   ...
                                        str_subjName,                   ...
                                        str_region,                     ...
                                        str_surfaceType);
                    process_count = process_count + 1;
                    C.arr_process{process_count} = str_index;
                    C.mmap_indexCache(str_index) = process_count;
                end
            end
        end
    end
end

% Create an array to handle processing in subject-order
processSubj_count = 0;
for hemi=1:numel(C.mcstr_brainHemi)
    str_hemi    = C.mcstr_brainHemi{hemi};
    for curvFunc=1:numel(C.mcstr_curvFunc)
        str_curvFunc            = C.mcstr_curvFunc{curvFunc};
        for region=1:numel(C.mcstr_brainRegion)
            str_region      = C.mcstr_brainRegion{region};
            for surfaceType = 1:numel(C.mcstr_surfaceType)
                str_surfaceType = C.mcstr_surfaceType{surfaceType};
                for subj=1:numel(C.mc_subjectInfo)
                    str_subjName        = C.mc_subjectInfo{subj}.mstr_subjLabel; 
                    str_index = sprintf('%s.%s.%s.%s.%s',               ...
                                    str_hemi,                           ...
                                    str_curvFunc,                       ...
                                    str_subjName,                       ...
                                    str_region,                         ...
                                    str_surfaceType);
                    processSubj_count = processSubj_count + 1;
                    C.arr_processSubjIndex(processSubj_count) =         ...
                            C.mmap_indexCache(str_index);
                end
            end
        end
    end
end

C.mb_mapDefined = 1;

[C.mstack_proc, element] = pop(C.mstack_proc);

