function [C, elementData, a_status] ...
    = mapindex_centroidsAnalyze(C, astr_mapIndex, elementData)

% NAME
%
%  function [C, elementData, a_status] =        ...
%               mapindex_centroidsAnalyze(C, astr_mapIndex, elementData)
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
%       This method analyzes centroids for additional information -- most
%       notably, each group of centroid data (gid-based) is processed for
%       its mean and std (on a positive and negative basis) and returned
%       in <adata>.
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
%       o <adata> contains the mean/std of each pos/neg gid centroid group.
%       o group centroid stored in group analysis dir.
%
% NOTE:
%
%       o Function WILL fail if underlying number of groups is too large!
%
% HISTORY
% 21 January 2010
% o Initial design and coding.
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
        try
            fill([x1 x2 x3 x4], [y1 y2 y3 y4], C.mc_colorSpec{point});
        catch ME
            if ~strcmp(astr_mapIndex, str_mapIndexPrev)
                C.mc_colorSpec{point}
                colprintf('50.30', 'Invalid region fill colorSpec (continuing)...',...
                        '[ %s ]\n', astr_mapIndex);
                colprintf('50.50', 'Total region count', '[ %d ]\n', cols);
                fprintf(1, '\t\t\tX: ');
                fprintf(1, '%10.5f',   [x1 x2 x3 x4]);
                fprintf(1, '\n\t\t\tY: ');
                fprintf(1, '%10.5f', [y1 y2 y3 y4]);
                fprintf('\n');
                str_mapIndexPrev = astr_mapIndex;
            end
        end
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

function meanstd_reportSave(av_M, av_S, av_gidIndex, acstr_groupMembers, astr_fileName)
    %
    % ARGS
    % INPUT
    %
    % OUTPUT
    %   av_M, av_S              matrix          column (group) dominant vectors
    %   av_gidIndex             vector          groud ids
    %   acstr_groupMembers      cell string     Subjects in each group
    %   astr_fileName           string          filename to save to
    %
    % PRECONDITIONS
    %   o av_M and av_S are column vectors of form:
    %
    %           x1
    %           y1
    %
    % DESC
    % Saves a file to group analysis dir.
    %
    % HISTORY
    % 21 January 2010
    % o Initial design and coding.
    %

    colw        = 15;
    prec        = 5;

    [rows cols]         = size(av_M);
    fid                 = fopen(astr_fileName, 'w');
    c_strFieldNames     = { 'gid', 'mean(x)', 'mean(y)', 'std(x)',      ...
                            'std(y)', 'std_length', 'rms(std)', '    group_subjects'};
    for header = 1:numel(c_strFieldNames)
        fprintf(fid, '%*s', colw, c_strFieldNames{header});
    end
    fprintf(fid, '\n');

    for group = 1:cols
        fprintf(fid, '%*d', colw, av_gidIndex(group));
        fprintf(fid, '%*.*f', colw, prec, av_M(1, group));
        fprintf(fid, '%*.*f', colw, prec, av_M(2, group));
        fprintf(fid, '%*.*f', colw, prec, av_S(1, group));
        fprintf(fid, '%*.*f', colw, prec, av_S(2, group));
        fprintf(fid, '%*.*f', colw, prec, sqrt(av_S(1, group)^2 + av_S(2, group)^2));
        fprintf(fid, '%*.*f', colw, prec, rms(av_S(:,group)));
        for subj = 1:numel(acstr_groupMembers{group})
            cstr_subj = acstr_groupMembers{group};
            fprintf(fid, '%*s ', colw, cstr_subj{subj});
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
end

function groupSeparation_analyze(aM_M, aM_S, av_gid,                    ...
                                    astr_outDir, astr_fileStem, astr_sign)
    %
    % ARGS
    % INPUT
    %   aM_M, aM_S              matrix          column (group) dominant vectors
    %   av_gid                  vector          group id lookup array
    %   astr_fileName           string          filename stem
    %   atr_sign                string          sign: 'pos' or 'neg'
    %
    % DESC
    %   Wrapper about the <separationFactor_analyze> function. Calls once for
    %   each permutation of underlying groups
    %

    groups              = size(aM_M, 2);
    M_permutation       = binomialInd_2find(groups);
    groupings           = size(M_permutation, 1);
    M_mean              = zeros(2, 2);
    M_std               = zeros(2, 2);
    for permutation = 1:groupings
        v_group = M_permutation(permutation, :);
        gid1    = av_gid(v_group(1));
        gid2    = av_gid(v_group(2));
        M_mean(:, 1)    = aM_M(:, v_group(1));
        M_mean(:, 2)    = aM_M(:, v_group(2));
        M_std(:, 1)     = aM_S(:, v_group(1));
        M_std(:, 2)     = aM_S(:, v_group(2));
        str_g1  = int2str(gid1);
        str_g2  = int2str(gid2);
        separationFactor_analyze(M_mean, M_std, str_g1, str_g2,         ...
                                    astr_outDir, astr_fileStem, astr_sign);
    end
end

function separationFactor_analyze(av_M, av_S,   astr_g1, astr_g2,       ...
                                                astr_outDir,            ...
                                                astr_fileStem, astr_sign)
    %
    % ARGS
    % INPUT
    %   av_M, av_S              matrix          column (group) dominant vectors
    %   astr_g1, astr_g2        string          names for group index 1 and 2
    %   astr_outDir             string          directory for output files
    %   astr_fileStem           string          fileStem for output files
    %   atr_sign                string          sign: 'pos' or 'neg'
    %
    % DESC
    %   Performs an "explicit" visual analysis of possible overlap between
    %   rectangular regions <astr_g1> and <astr_g2>.
    % 
    % PRECONDITIONS
    %   o Assumes two groups.
    %   o av_M and av_S are column vectors of form:
    %
    %           xA xB
    %           yA yB
    %
    % POSTCONDITIONS
    %   o If any separation distances are positive, indicating a clean 
    %     separation between groups, create an appropriately named 
    %     'tag' file.
    %   o Several text files are saved to working directory containing
    %     results of different analyses.
    %
    % HACK-ish
    %   o method uses out-of-scope <str_analysis> variable.
    %
    % HISTORY
    % 10 September 2010
    % o Initial design and coding.
    %
    % 27 September 2010
    % o Expansion to arbitrary group "names".
    %

    % Remove the file 'separable.txt' if it exists in this directory:
    str_fileName        = sprintf('%s/%s-%s-%s-%s.txt', astr_outDir,   ...
                                    astr_sign, astr_g1, astr_g2, astr_fileStem);
    str_fileTag = sprintf('%s-sep', str_fileName);
    str_fileOP  = sprintf('%s-overlap', str_fileName);
    str_fileA1  = sprintf('%s/%s-A%s-%s.txt', astr_outDir, astr_sign, astr_g1, str_analysis);
    str_fileA2  = sprintf('%s/%s-A%s-%s.txt', astr_outDir, astr_sign, astr_g2, str_analysis);
    if exist(str_fileTag)
        delete(str_fileTag);
    end

    str_AB      = sprintf('%s%s', astr_g1, astr_g2);
    str_BA      = sprintf('%s%s', astr_g2, astr_g1);
    
    pA          = av_M(:,1);
    pB          = av_M(:,2);
    dA          = av_S(:,1);
    dB          = av_S(:,2);

    % Corner points of the two group boxes in the x direction:
    %   Two boxes, so four x corner points.
    %   Here, 'l' and 'r' are 'left' and 'right'
    x_la        = pA(1) - 0.5 * dA(1);
    x_ra        = pA(1) + 0.5 * dA(1);
    x_lb        = pB(1) - 0.5 * dB(1);
    x_rb        = pB(1) + 0.5 * dB(1);

    % Corner points of the two group boxes in the y direction:
    %   Two boxes, so four y corner points.
    %   Here, 't' and 'b' are 'top' and 'bottom'
    y_ta        = pA(2) + 0.5 * dA(2);
    y_ba        = pA(2) - 0.5 * dA(2);
    y_tb        = pB(2) + 0.5 * dB(2);
    y_bb        = pB(2) - 0.5 * dB(2);

    % Vectorize the regions
    v_R1        = [x_la, y_ba, x_ra, y_ta];
    v_R2        = [x_lb, y_bb, x_rb, y_tb];

    % Percentage region overlap
    [f_overlap, f_A1, f_A2] = region_percOverlap(v_R1, v_R2);

    % Determine the separations for the possible conditions in
    %   x and y.
    x_ABsep     = x_lb - x_ra;
    x_BAsep     = x_la - x_rb;
    y_ABsep     = y_ba - y_tb;
    y_BAsep     = y_bb - y_ta;

    % Now, create the output file:
    colw                = 20;
    prec                = 5;
    firstcol            = 60;

    [rows cols]         = size(av_M);
    fid                 = fopen(str_fileName, 'w');
    str_xABsep          = sprintf('x%ssep', str_AB);
    str_yABsep          = sprintf('y%ssep', str_AB);
    str_xBAsep          = sprintf('x%ssep', str_BA);
    str_yBAsep          = sprintf('y%ssep', str_BA);
    c_strFieldNames     = { 'mapIndex',                 ...
                            str_xABsep, str_xBAsep,     ...
                            str_yABsep, str_yBAsep };
    for header = 1:numel(c_strFieldNames)
        colww = colw;
        if header ==  1, colww = firstcol; end
        fprintf(fid, '%*s', colww, c_strFieldNames{header});
    end
    fprintf(fid, '\n');
    fprintf(fid, '%*s',     firstcol, ...
                            sprintf('%s-%s-dist', astr_sign, str_analysis));
    fprintf(fid, '%*.*f',   colw, prec, x_ABsep);
    fprintf(fid, '%*.*f',   colw, prec, x_BAsep);
    fprintf(fid, '%*.*f',   colw, prec, y_ABsep);
    fprintf(fid, '%*.*f\n', colw, prec, y_BAsep);

    f_avlen_x   = 0.5 * (dA(1) + dB(1));
    f_avlen_y   = 0.5 * (dA(2) + dB(2));
    fprintf(fid, '%*s',     firstcol, ...
                            sprintf('%s-%s-ratio', astr_sign, str_analysis));
    fprintf(fid, '%*.*f',   colw, prec, x_ABsep / f_avlen_x);
    fprintf(fid, '%*.*f',   colw, prec, x_BAsep / f_avlen_x);
    fprintf(fid, '%*.*f',   colw, prec, y_ABsep / f_avlen_y);
    fprintf(fid, '%*.*f\n', colw, prec, y_BAsep / f_avlen_y);

    if x_ABsep > 0 | x_BAsep > 0 | y_ABsep > 0 | y_BAsep > 0
        fidsep  = fopen(str_fileTag, 'w');
        if x_ABsep > 0
            fprintf(fidsep, '%s\t%*.*f%*.*f\n', str_xABsep, colw, prec, x_ABsep, ...
                                                    colw, prec, x_ABsep / f_avlen_x);
        end
        if x_BAsep > 0
            fprintf(fidsep, '%s\t%*.*f%*.*f\n', str_xBAsep, colw, prec, x_BAsep, ...
                                                    colw, prec, x_BAsep / f_avlen_x);
        end
        if y_ABsep > 0
            fprintf(fidsep, '%s\t%*.*f%*.*f\n', str_yABsep, colw, prec, y_ABsep, ...
                                                    colw, prec, y_ABsep / f_avlen_y);
        end
        if y_BAsep > 0
            fprintf(fidsep, '%s\t%*.*f%*.*f\n', str_yBAsep, colw, prec, y_BAsep, ...
                                                    colw, prec, y_BAsep / f_avlen_y);
        end
        fclose(fidsep);
    end
    fid_op              = fopen(str_fileOP, 'w');
    fid_A1              = fopen(str_fileA1, 'w');
    fid_A2              = fopen(str_fileA2, 'w');
    fprintf(fid_op,     '%f\n', f_overlap);
    fprintf(fid_A1,     '%f\n', f_A1);
    fprintf(fid_A1,     '%f ',  v_R1);
    fprintf(fid_A2,     '%f\n', f_A2);
    fprintf(fid_A2,     '%f ',  v_R2);
    fclose(fid_A2);
    fclose(fid_A1);
    fclose(fid_op);
    fclose(fid);
end

function meanstd_distance(av_M, av_S, astr_fileName, astr_sign)
    %
    % ARGS
    % INPUT
    %
    % OUTPUT
    %   av_M, av_S              matrix          column (group) dominant vectors
    %   astr_fileName           string          filename to save to
    %   atr_sign                string          sign: 'pos' or 'neg'
    %
    % DESC
    % Saves centroid distances to file.
    % 
    % PRECONDITIONS
    %   o av_M and av_S are column vectors of form:
    %
    %           x1
    %           y1
    %
    %
    % HISTORY
    % 25 January 2010
    % o Initial design and coding.
    %
    % OBSOLETE as of late 2010!! DO NOT USE!
    %

    colw                = 20;
    prec                = 5;
    firstcol            = 60;

    [rows cols]         = size(av_M);
    fid                 = fopen(astr_fileName, 'w');
    c_strFieldNames     = { 'mapIndex', 'x-sep', 'y-sep', 'c-sep',      ...
                            'min-x-width', 'min-y-width',               ...
                            'min-sep', 'rms-mean'};
    for header = 1:numel(c_strFieldNames)
        colww = colw;
        if header ==  1, colww = firstcol; end
        fprintf(fid, '%*s', colww, c_strFieldNames{header});
    end
    fprintf(fid, '\n');

    %
    % Hack -- assuming only 2 groups.
    f_xDist             = abs(av_M(1,1) - av_M(1,2));
    f_yDist             = abs(av_M(2,1) - av_M(2,2));
    f_centroidDist      = vector_distance(av_M(:,1), av_M(:,2));
    f_stdXDist          = (av_S(1,1) + av_S(1,2))/2;
    f_stdYDist          = (av_S(2,1) + av_S(2,2))/2;
    f_stdlength1        = sqrt(av_S(1, 1)^2 + av_S(2, 1)^2);
    f_stdlength2        = sqrt(av_S(1, 2)^2 + av_S(2, 2)^2);
    f_stdlengthAve      = (f_stdlength1 + f_stdlength2)/4;
    f_rms1              = rms(av_S(:,1));
    f_rms2              = rms(av_S(:,2));
    f_rmsAve            = (f_rms1 + f_rms2)/4;
    fprintf(fid, '%*s',     firstcol, ...
                            sprintf('%s-%s-dist', astr_sign, str_analysis));
    fprintf(fid, '%*.*f',   colw, prec, f_xDist);
    fprintf(fid, '%*.*f',   colw, prec, f_yDist);
    fprintf(fid, '%*.*f',   colw, prec, f_centroidDist);
    fprintf(fid, '%*.*f',   colw, prec, f_stdXDist);
    fprintf(fid, '%*.*f',   colw, prec, f_stdYDist);
    fprintf(fid, '%*.*f',   colw, prec, f_stdlengthAve);
    fprintf(fid, '%*.*f\n', colw, prec, f_rmsAve);

    fprintf(fid, '%*s',     firstcol, ...
                            sprintf('%s-%s-ratio', astr_sign, str_analysis));
    fprintf(fid, '%*.*f',   colw, prec, f_xDist/f_xDist);
    fprintf(fid, '%*.*f',   colw, prec, f_yDist/f_yDist);
    fprintf(fid, '%*.*f',   colw, prec, f_centroidDist/f_centroidDist);
    fprintf(fid, '%*.*f',   colw, prec, f_xDist/f_stdXDist);
    fprintf(fid, '%*.*f',   colw, prec, f_yDist/f_stdYDist);
    fprintf(fid, '%*.*f',   colw, prec, f_centroidDist/f_stdlengthAve);
    fprintf(fid, '%*.*f\n', colw, prec, f_centroidDist/f_rmsAve);
    fclose(fid);
end

function subjCentroid_analyze(astr_title)
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

    [C str_wd status]       = mapindex_workingDirGet(C, astr_mapIndex);

    if b_negPlotsOK
        plot_fill(v_Mng, v_Sng, v_gidIndex);
        meanstd_reportSave(v_Mng, v_Sng, v_gidIndex, cstr_groupMembers,         ...
                            sprintf('%s/neg-%s.txt', str_wd, astr_title));
        groupSeparation_analyze(v_Mng, v_Sng, v_gidIndex, str_wd, astr_title, 'neg');
    end
    plot_fill(v_Mpg, v_Spg, v_gidIndex);
    meanstd_reportSave(v_Mpg, v_Spg, v_gidIndex, cstr_groupMembers,             ...
                            sprintf('%s/pos-%s.txt', str_wd, astr_title));
    groupSeparation_analyze(v_Mpg, v_Spg, v_gidIndex, str_wd, astr_title, 'pos');
    grid;
    xlabel('X group mean centroid position');
    ylabel('Y group mean centroid position');
    title(astr_title);
    str_epsFile = sprintf('%s/%s.eps', str_wd, astr_title);
    str_jpgFile = sprintf('%s/%s.jpg', str_wd, astr_title);
    colprintf(C, '', '[ ok ]\n');
    lprintf(C, 'Save %s', astr_title);
    imprint(C, str_epsFile, str_jpgFile);
    close(fh);
end

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%


C.mstack_proc 	        = push(C.mstack_proc, 'mapindex_centroidsAnalyze');

persistent      subjIndex;
persistent      map_subjCentroid;
persistent      str_curvFuncPrev;
persistent      str_mapIndexPrev;
subjCount       = numel(keys(C.mmap_subjectInfo));

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

%if strcmp(str_core, 'centroid')

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
        str_fileStem    = sprintf('centroids-analyze-%s.%s.%s.%s',      ...
                            str_hemi,                                   ...
                            str_curvFunc,                               ...
                            str_region,                                 ...
                            str_surfaceType);
        str_analysis    = sprintf('%s.%s.%s.%s',                        ...
                            str_hemi,                                   ...
                            str_curvFunc,                               ...
                            str_region,                                 ...
                            str_surfaceType);
        lprintf(C, '%s', str_fileStem);
        subjCentroid_analyze(str_fileStem);
        colprintf(C, '', '[ ok ]\n');
    end
    C.m_verbosityLevel       = verbosityLevel;
%end

[C.mstack_proc, element] = pop(C.mstack_proc);

end