function [C, elementData, a_status] ...
    = mapindex_histogramPlot(C, astr_mapIndex, elementData)     
%
% NAME
%
%  function [C, elementData, a_status] ...
%      = mapindex_histogramPlot(C, astr_mapIndex, elementData)
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
%
% DESCRIPTION
%
%       This method plots the histogram specified by <astr_mapIndex>. A jpg and
%       eps file of the plot is also generated and saved in the subject-specific
%       analysis directory.
%       
%       Also, all the plots for a given subject are combined into one figure and
%       saved to the group analysis directory.
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
%       o <adata> referenced by the index.
%       o boolean <a_status>.
%       o subject-specific plot jpg and eps stored in subject analysis dir.
%       o group plot stored in group analysis dir.
%       
% NOTE:
%
% HISTORY
% 01 October 2009
% o Initial design and coding.
%

%%%%%%%%%%%%%%
%%% Nested functions
%%%%%%%%%%%%%%

function figure_plot(adata)
    xout                = adata(:, 1);
    fx                  = adata(:, 2);
    bar(xout, fx);
    v_axis              = elementData{C.mi_indexAxis};

    v                   = axis;
    v(1)                = v_axis(1);
    v(2)                = v_axis(2);
    if C.mb_yMinMax
        v(3)            = v_axis(3);
        v(4)            = v_axis(4);
    end

    title(str_nodeIndex);
    grid;

end

function figure_print(astr_outputDir, astr_outputFileStem)
    str_figFile         = sprintf('%s/%s', astr_outputDir, astr_outputFileStem);
    print('-depsc2',    '-r300', sprintf('%s.eps', str_figFile));
    print('-djpeg',     '-r300', sprintf('%s.jpg', str_figFile));
end

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%


C.mstack_proc 	        = push(C.mstack_proc, 'mapindex_histogramPlot');

persistent      subjIndex;
persistent      figureCount;
persistent      str_curvFuncPrev;
subjCount       = numel(keys(C.mmap_subjectInfo));

if isempty(subjIndex),          subjIndex               = 1; end;
if isempty(figureCount),        figureCount             = 1; end;


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

lprintf(C, 'Plotting %s', astr_mapIndex);

str_nodeIndex       = basename(astr_mapIndex, '.histogram');
str_axisIndex       = sprintf('%s.%s',              ...
                            str_nodeIndex,          ...
                            'axis');

M                   = grid_make([1:subjCount]);
[rows, cols]        = size(M);
adata               = elementData{C.mi_indexHistogram};

if length(adata)
    %
    % Single plot

    fh = figure(1);
    str_visibility      = 'on';
    if C.mb_offScreenCentroidPlots
        str_visibility  = 'off';
    end
    set(fh, 'Visible', str_visibility);
    figure_plot(adata);
    figure_print(C.mmap_subjectInfo(str_subjName).mstr_workingDir,      ...
                sprintf('hist-%s', str_nodeIndex));

    if(C.mb_drawCumulativeHistPlots)
        % Cumulative plot
        figure(subjCount + 1);
        subplot(rows, cols, subjIndex);
        figure_plot(adata);
    end

    colprintf(C, '', '[ %d ]\n', subjIndex);
end

% Increase subject index and optionally perform the cumulative save
subjIndex           = subjIndex+1;
if mod(subjCount, subjIndex) == subjCount
    subjIndex       = 1;
    str_fileStem    = sprintf('hist-cumulative-%s.%s.%s.%s',        ...
                        str_hemi,                                   ...
                        str_curvFunc,                               ...
                        str_region,                                 ...
                        str_surfaceType);
    figureCount = figureCount + 1;
    lprintf(C, 'Saving %s', str_fileStem);
    [C str_wd status]       = mapindex_workingDirGet(C, astr_mapIndex);
    figure_print(str_wd, str_fileStem);
    colprintf(C, '', '[ ok ]\n');
    str_curvFuncPrev        = str_curvFunc;
end

C.m_verbosityLevel       = verbosityLevel;

[C.mstack_proc, element] = pop(C.mstack_proc);

end