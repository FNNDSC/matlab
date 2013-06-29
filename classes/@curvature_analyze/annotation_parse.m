function [C, a_status] = annotation_parse(C, astr_subjectDir)
%
% NAME
%
%  function [C, a_status] = annotation_parse(C, astr_subjectDir)
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze  class
%       astr_subjectDir	string          subject directory
%
% OUTPUT
%       C               class           curvature_analyze class
%       a_status        int             return status
%
% DESCRIPTION
%
%       This method parses the class-internal annotation file, and intializes
%       annotation-related data structures.
%
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%
% POSTCONDITIONS
%
%       o cortical parcellation structures named.
%       o group output directory structure created.
%       o boolean <a_status>.
%       
% NOTE:
%
% HISTORY
% 08 January 2010
% o Initial design and coding.
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

function [acstr_regions, elementRemoved] = region_remove(acstr_regions)
    annotlen            = numel(acstr_regions);
    elementRemoved      = 0;
    for i=1:annotlen
        for j=1:numel(C.mcstr_brainRegionSkip)
            if strcmp(C.mcstr_brainRegionSkip{j}, acstr_regions{i})
                acstr_regions(i) = [];
                elementRemoved   = 1;
                return;
            end
        end
    end
end

C.mstack_proc 	                = push(C.mstack_proc, 'annotation_parse');

str_annotationFile              = sprintf('%s/%s/lh.%s',                ...
                                    astr_subjectDir,                    ...
                                    C.ms_annotation.mstr_labelDir,      ...
                                    C.ms_annotation.mstr_annotFile);

if ~exist(str_annotationFile)
    error_exit(C, '1', sprintf('Could not access annotation file %s\n\n', str_annotationFile));
end

[v_list, v_label, annot]        = read_annotation(str_annotationFile);
c_structNames                   = annot.struct_names;

if C.mb_brainRegionSkip
    elementRemoved = 1;
    while elementRemoved
        [c_structNames, elementRemoved] = region_remove(c_structNames);
    end
end


str_orig                        = C.mcstr_brainRegion{1};
C.mcstr_brainRegion             = cell(1, numel(c_structNames)+1);
C.mcstr_brainRegion(1:numel(c_structNames))     = c_structNames;
C.mcstr_brainRegion{numel(c_structNames)+1}     = str_orig;

str_pwd = pwd;
cd(C.mstr_analysisPath);
if exist(C.ms_annotation.mstr_annotFile) ~= 7
    dir_create(C.ms_annotation.mstr_annotFile);
end
for iname = 1:numel(C.mcstr_brainRegion)
    str_outDir  = [ C.mstr_analysisPath '/' C.ms_annotation.mstr_annotFile ...
                    '/' C.mcstr_brainRegion{iname}];
    if exist(str_outDir) ~= 7. dir_create(str_outDir); end
end


cd(str_pwd);
a_status        = 1;
[C.mstack_proc, element]        = pop(C.mstack_proc);

end
