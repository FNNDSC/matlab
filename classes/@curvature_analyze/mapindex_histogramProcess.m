function [C, elementData, a_status] ...
    = mapindex_histogramProcess(C, astr_mapIndex, elementData)     
%
%  function [C, histogram, curv, centroid, stats, axis, annotArg, a_status]
%       = mapindex_histogramProcess(C, astr_mapIndex,elementData)     
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
%       This method processes the 'curvature' data for a map index
%       to create the resultant histogram.
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
%       o the curvature data is processed according to:
%               - bound limited on the x-axis
%               - normalization
%       o the node 'histogram' and 'axis' data maps are populated
%
% NOTE:
%
% HISTORY
% 28 September 2009
% o Initial design and coding.
%
% 14 October 2009
% o 'axis' expansions.
% 

C.mstack_proc 	        = push(C.mstack_proc, 'mapindex_histogramProcess');

a_status        = 0;
adata           = [];

[       str_hemi,               ...
        str_curvFunc,           ...
        str_subjName,           ...
        str_region,             ...
        str_surfaceType,        ...
        str_core,               ...
        a_status] = map_indexSplit(C, astr_mapIndex);


if C.mb_regionFilter
    iregion     = find(ismember(C.mcstr_regionFilter, str_region)==1);
    if isempty(iregion), return, end;
end

verbosityLevel          = C.m_verbosityLevel;
C.m_verbosityLevel      = 2;

lprintf(C, 'Processing %s', astr_mapIndex);

str_nodeIndex               = sprintf('%s.%s.%s.%s.%s',     ...
    str_hemi,               ...
    str_curvFunc,           ...
    str_subjName,           ...
    str_region,             ...
    str_surfaceType);

str_curvatureIndex          = sprintf('%s.%s',              ...
    str_nodeIndex,          ...
    'curvature');

str_axisIndex               = sprintf('%s.%s',              ...
    str_nodeIndex,          ...
    'axis');

v_curv                  = elementData{C.mi_indexCurvature};
if length(v_curv)
    f_curvMin           = 0;
    f_curvMax           = f_curvMin;
    if C.mb_lowerLimitSet
        v_curv          = v_curv(v_curv >= C.mf_lowerLimit);
        f_curvMin       = C.mf_lowerLimit;
    else
        f_curvMin       = min(v_curv);
    end
    if C.mb_upperLimitSet
        v_curv          = v_curv(v_curv <= C.mf_upperLimit);
        f_curvMax       = C.mf_upperLimit;
    else
        f_curvMax       = max(v_curv);
    end

    if isempty(v_curv)
      error_exit(C, 'err:1', 	...
      '<v_curv> for %s is empty. \nPerhaps too strict upper and lower filters are set?\n\n',...
      astr_mapIndex);
    end
    %
    % Create axis range...
    v_axis              = [f_curvMin f_curvMax];
    if C.mb_yMinMax
        v_axis(3)       = C.mf_ymin;
        v_axis(4)       = C.mf_ymax;
    end
    elementData{C.mi_indexAxis} = v_axis;

    %      f_dt                = (f_curvMax - f_curvMax) / C.m_histBins;
    %      f_t                 = f_curvMin: f_dt: f_curvMax - f_dt;
    [fx, xout]          = hist(v_curv, C.m_histBins);
    if C.mb_histNormalize, fx = fx ./ numel(v_curv) * C.m_histBins; end
    try
        adata		= [xout' fx'];
    catch ME
	keyboard;
    end
    elementData{C.mi_indexHistogram}    = adata;

    colprintf(C, '', '[ ok ]\n');
else
    colprintf(C, '', '[ NaN ]\n');
    adata               = NaN;
end
C.m_verbosityLevel       = verbosityLevel;


[C.mstack_proc, element] = pop(C.mstack_proc);

