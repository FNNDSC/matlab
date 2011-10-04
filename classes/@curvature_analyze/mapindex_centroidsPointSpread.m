function [C, elementData, a_status] ...
    = mapindex_centroidsPointSpread(C, astr_mapIndex, elementData)   
%
% NAME
%
%  function [C, elementData, a_status]
%       = mapindex_centroidsPointSpread(C, astr_mapIndex, elementData)     
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
%       This method is essentially a "merging" of the centroidsPlot and
%       centroidsAnalyze methods -- display both on the same set of axes.
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
% 02 June 2010
% o Initial design and coding from centroidsPlot and centroidsAnalyze.
%

%%%%%%%%%%%%%%
%%% Nested functions
%%%%%%%%%%%%%%

function [av_X, av_Y] = centroids_collect(astr_field)
    %
    % ARGS
    % INPUT
    % astr_field                string          one of 'n', 'p', or 'c'
    %                                           to denote the negative,
    %                                           positive, or cumulative
    %                                           centroid.
    % OUTPUT
    % av_X, av_Y                vector          the constituent x and y
    %                                           centroids for each subject.                                          
    %                                           
    % DESC
    % Collect across the subject maps the centroids for field <astr_field> into
    % X and Y vectors.
    % 
    cstr_subj           = keys(map_subjCentroid);
    str_fieldNameX      = sprintf('x%s', astr_field);
    str_fieldNameY      = sprintf('y%s', astr_field);
    for subj = 1:numel(cstr_subj)
        str_key         = cstr_subj{subj};
        s_centroid      = map_subjCentroid(str_key);
        av_X(subj)      = getfield(s_centroid, str_fieldNameX);
        av_Y(subj)      = getfield(s_centroid, str_fieldNameY);
    end
end

function [av_gid av_gidIndex]       = groupMembership_find()
    %
    % ARGS
    % INPUT
    % 
    % OUTPUT
    %   av_gid          vector          Vector with indices equal to gid
    %                                   and index value equal to number of
    %                                   members in group
    %   av_gidIndex     vector          Vector with ordinal index corresponding
    %                                   to ordinal gid. This is only really 
    %                                   necessary if gids are not strictly
    %                                   ordinal, i.e. gid(1) != 1, for e.g.
    %    
    % DESC
    % Process the subject map gid and generate a group membership vector.
    %
    av_gid              = [];
    av_gidIndex         = [];
    cstr_subj           = keys(map_subjCentroid);
    for subj = 1:numel(cstr_subj)
        str_key         = cstr_subj{subj};
        ms_subjInfo     = C.mmap_subjectInfo(str_key);
        gid             = ms_subjInfo.mgid;
        try
            av_gid(gid)         = av_gid(gid) + 1;
            av_gidIndex(gid)    = gid;
        catch exception
            av_gid(gid)         = 1;
            av_gidIndex(gid)    = gid;
        end
    end
end

function [av_Xg av_Yg acstr_label]  = gid_collect(av_X, av_Y, a_gid)
    %
    % ARGS
    % INPUT
    %  av_X av_Y        vector          X and Y ordered by C.mmap_subjectInfo
    %                                   keys
    %  a_gid            int             gid to collect
    %  
    %  OUTPUT
    %  av_Xg av_Yg      vector          X and Y vector that correspond to
    %                                   subjects with the passed <a_gid>.
    %  acstr_label      cell string     subj labels corresponding to each
    %                                   indexed gid.
    %
    % DESC
    % Filter input av_X and av_Y for passed <a_gid>, store in av_Xg av_Yg.
    %
    cstr_subj           = keys(map_subjCentroid);
    start               = 1;
    av_Xg               = [];
    av_Yg               = [];
    acstr_label         = {};
    for subj = 1:numel(cstr_subj)
        str_key         = cstr_subj{subj};
        ms_subjInfo     = C.mmap_subjectInfo(str_key);
        gid             = ms_subjInfo.mgid;
        if gid == a_gid
            av_Xg(start)        = av_X(subj);
            av_Yg(start)        = av_Y(subj);
            acstr_label{start}  = ms_subjInfo.mstr_subjLabel;
            start               = start + 1;
        end
    end
end

function plot_fill(av_M, av_S, av_gidIndex)
    %
    % ARGS
    % INPUT
    %
    % OUTPUT
    %   av_M, av_S      vector          Vector defining the mean and std
    %                                   of a group centroid
    %   av_gidIndex     vector          gid of av_M and av_S
    %
    % PRECONDITIONS
    %   o av_M and av_S are column vectors of form:
    %
    %           x1
    %           y1
    %
    % DESC
    % At each <av_M, av_S> (mean, std) plot a point at the av_M and surround
    % with a rectangle of av_S
    %

    [rows cols] = size(av_M);
    v_Xr        = [];
    v_Yr        = [];
    v_Xl        = [];
    v_Yl        = [];
    c_r         = cell(1,1);
    c_l         = cell(1,1);
    r           = 1;
    l           = 1;

    c_colorSpec = { 'r', 'g', 'b', 'c', 'm', 'y', 'k' };
    for point = 1:cols
        if point <= 7
            str_lineSpec        = C.mc_lineStyle{point};
        else
            str_lineSpec        = '-or';
        end
        % Center point:
        plot(av_M(1, point), av_M(2, point), str_lineSpec,        ...
                      'MarkerFaceColor', C.mc_colorSpec{point});
        % Std region rectangle
        x1      = av_M(1, point) + av_S(1, point)/2;
        x2      = x1;
        x3      = av_M(1, point) - av_S(1, point)/2;
        x4      = x3;
        y1      = av_M(2, point) + av_S(2, point)/2;
        y2      = av_M(2, point) - av_S(2, point)/2;
        y3      = y2;
        y4      = y1;
        fill([x1 x2 x3 x4], [y1 y2 y3 y4], C.mc_colorSpec{point});
        str_label       = sprintf('group %d', av_gidIndex(point));
        if mod(point, 2)
            str_side    = '\rightarrow';
            c_r{r}      = sprintf(' %s %s ', str_label, str_side);
            v_Xr(r)     = av_M(1, point);
            v_Yr(r)     = av_M(2, point);
            r           = r + 1;
        else
            str_side    = '\leftarrow';
            c_l{l}      = sprintf(' %s %s ', str_side, str_label);
            v_Xl(l)     = av_M(1, point);
            v_Yl(l)     = av_M(2, point);
            l           = l + 1;
        end
    end
    if numel(v_Xl)
        text(v_Xl, v_Yl, c_l, 'FontSize', 8, 'HorizontalAlignment', 'left');
    end
    if numel(v_Xr)
        text(v_Xr, v_Yr, c_r, 'FontSize', 8, 'HorizontalAlignment', 'right');
    end
end

function plot_label(av_X, av_Y, acstr_label)
    %
    % ARGS
    % INPUT
    %
    % OUTPUT
    %   av_X, av_Y      vector          Vector defining the plotted
    %                                   centroid points to label
    %   acstr_label     cell string     Labels (one for each x,y pair)
    %
    % DESC
    % Plots a text label for each centroid point. Labels alternate
    % on the left and right side of the plotted centroid point, and
    % label text corresponds to the subject label.
    %

    v_Xr        = [];
    v_Yr        = [];
    v_Xl        = [];
    v_Yl        = [];
    c_r         = cell(1,1);
    c_l         = cell(1,1);
    r           = 1;
    l           = 1;
    for point = 1:numel(av_X)
        str_label       = acstr_label{point};
        if mod(point, 2)
            str_side    = '\rightarrow';
            c_r{r}      = sprintf(' %s %s ', str_label, str_side);
            v_Xr(r)     = av_X(point);
            v_Yr(r)     = av_Y(point);
            r           = r + 1;
        else
            str_side    = '\leftarrow';
            c_l{l}      = sprintf(' %s %s ', str_side, str_label);
            v_Xl(l)     = av_X(point);
            v_Yl(l)     = av_Y(point);
            l           = l + 1;
        end
    end
    if numel(v_Xl)
        text(v_Xl, v_Yl, c_l, 'FontSize', 8, 'HorizontalAlignment', 'left');
    end
    if numel(v_Xr)
        text(v_Xr, v_Yr, c_r, 'FontSize', 8, 'HorizontalAlignment', 'right');
    end
end

function subjCentroid_pointSpread(astr_title)
    [v_Xn, v_Yn]        = centroids_collect('n');
    [v_Xp, v_Yp]        = centroids_collect('p');
    f_ymax              = max(v_Yp);
    f_xmin              = min(v_Xn);
    fh                  = subjCount*10;
    if max(v_Yn) > f_ymax, f_ymax = max(v_Yn);  end
    if isnan(min(v_Xn)),   f_xmin = 0.0;        end 
    figure(fh);
    str_visibility      = 'on';
    if C.mb_offScreenCentroidPlots
        str_visibility  = 'off';
    end
    set(fh, 'Visible', str_visibility);
    hold on;
    axis([f_xmin*1.5, max(v_Xp)*1.5, 0.0, f_ymax*1.1]);

    [v_gidComplete v_gidIndex]  = groupMembership_find();       
    v_gid                       = compress(v_gidComplete);
    v_gidIndex                  = compress(v_gidIndex);
    start                       = 0;
    cstr_subj                   = keys(map_subjCentroid);

    v_Mng                       = [];
    v_Sng                       = [];
    v_Mpg                       = [];
    v_Spg                       = [];
    cstr_groupMembers           = {};
    
    b_negPlotsOK                = 1;
    for group           = 1:numel(v_gid)

        [v_Xng v_Yng cstr_label]= gid_collect(v_Xn, v_Yn, v_gidIndex(group));
        [v_Xpg v_Ypg cstr_label]= gid_collect(v_Xp, v_Yp, v_gidIndex(group));

        v_negNaN        = isnan(v_Xng);
        if numel(v_gid) <= 7
            str_lineSpec = C.mc_pointStyle{group};
        else
            str_lineSpec = '-or';
        end
        if C.mb_useLines
            str_lineSpec = sprintf('-%s', str_lineSpec);
        end            

        if(~max(v_negNaN))
            plot( v_Xng, v_Yng, str_lineSpec,   ...
            'MarkerFaceColor', C.mc_colorSpec{group});
            if C.mb_centroidLabelPlot
                plot_label(v_Xng, v_Yng, cstr_label);
            end
        end
            plot( v_Xpg, v_Ypg, str_lineSpec,   ...
            'MarkerFaceColor', C.mc_colorSpec{group});
            if C.mb_centroidLabelPlot
                plot_label(v_Xpg, v_Ypg, cstr_label);
            end

        cstr_groupMembers{group}  = cstr_label;
        v_Mng(1, group) = mean(v_Xng);
        v_Mng(2, group) = mean(v_Yng);
        v_Sng(1, group) = std(v_Xng);
        v_Sng(2, group) = std(v_Yng);
        v_Mpg(1, group) = mean(v_Xpg);
        v_Mpg(2, group) = mean(v_Ypg);
        v_Spg(1, group) = std(v_Xpg);
        v_Spg(2, group) = std(v_Ypg);

        b_negPlotsOK    = b_negPlotsOK & ~max(v_negNaN);

        start   = v_gid(group)+start;
    end
    if b_negPlotsOK
        plot_fill(v_Mng, v_Sng, v_gidIndex);
    end
    plot_fill(v_Mpg, v_Spg, v_gidIndex);
    grid;
    xlabel('X centroid position');
    ylabel('Y centroid position');
    title(astr_title);
    [C str_wd status]       = mapindex_workingDirGet(C, astr_mapIndex);
    str_epsFile = sprintf('%s/%s.eps', str_wd, str_fileStem);
    str_jpgFile = sprintf('%s/%s.jpg', str_wd, str_fileStem);
    colprintf(C, '', '[ ok ]\n');
    lprintf(C, 'Save %s', str_fileStem);
    print('-depsc2', str_epsFile);
    print('-djpeg',  str_jpgFile);
    close(fh);
end

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%


C.mstack_proc 	        = push(C.mstack_proc, 'mapindex_centroidsPlot');

persistent      subjIndex;
persistent      map_subjCentroid;
persistent      str_curvFuncPrev;
subjCount       = numel(keys(C.mmap_subjectInfo));

%c_lineStyle     = { '-r+', '-og', '-*b', '-cx', '-ms', '-yd', '-k^' };

if isempty(subjIndex),          subjIndex        = 1;                   end;
if isempty(map_subjCentroid),   map_subjCentroid = containers.Map();    end;


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

str_nodeIndex       = basename(astr_mapIndex, '.centroid');

lprintf(C, 'Reading %s', astr_mapIndex);
s_centroid = elementData{C.mi_indexCentroid};
if ~isstruct(s_centroid)
    s_centroid      = C.ms_centroid;
end
map_subjCentroid(str_subjName) = s_centroid;
colprintf(C, '', '[ %d ]\n', subjIndex);

% Increase subject index and on rollover plot the centroids
subjIndex           = subjIndex+1;
if mod(subjCount, subjIndex) == subjCount
    subjIndex       = 1;
    str_fileStem    = sprintf('centroids-pointSpread-%s.%s.%s.%s',  ...
                        str_hemi,                                   ...
                        str_curvFunc,                               ...
                        str_region,                                 ...
                        str_surfaceType);
    lprintf(C, 'Plot %s', str_fileStem);
    subjCentroid_pointSpread(str_fileStem);
    colprintf(C, '', '[ ok ]\n');
end
C.m_verbosityLevel       = verbosityLevel;

[C.mstack_proc, element] = pop(C.mstack_proc);

end
