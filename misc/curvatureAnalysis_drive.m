function [C]    = curvatureAnalysis_drive(astr_annotFile, astr_groupFileID, varargin)
%
% NAME
%
%  function C = curvatureAnalysis_drive(        astr_annotFile,
%                                               astr_groupFileID,
%                                               [verbosity,             ]
%                                               [b_subjLabelFile_use,   ]
%                                               [cstr_surfaceSpec,      ]
%                                               [b_usePlotLines,        ]
%                                               [b_plotHistograms,      ]
%                                               [b_autodijk,            ]
%						[str_hemi,              ]
%                                               [str_subjSpec,          ]
%                                               [str_regionSpec,        ]
%                                               [cstr_curvSpec] )
%
% ARGUMENTS
% INPUT
%       astr_annotFile          string          the annotation file to process
%       astr_groupFileID        string          the groupID file
%
% OPTIONAL
%       verbosity               int     system verbosity level
%       b_subLabelFileUse       bool    if true, use existing subjectLabel
%                                               text files when plotting;
%                                               otherwise, label plots with
%                                               containing dir names
%       cstr_surfaceSpec        cell    (of strings) denoting the surfaces
%                                               to process
%       b_usePlotLines          int     set the "plot lines" bit in graphs.
%       b_plotHistograms        int     set the "plotHistogram" bit.
%       b_autodijk              int     if true, perform an autodijk analysis
%       str_hemi                string  if specified, process passed hemi
%	str_subjSpec	        string	if specified, process subject spec
%       str_regionSpec          string  if specified, use to define a region
%                                               sub spec.
%       cstr_curvSpec           cell    (of strings) if specified, use to set
%                                       the curvature functions to analyze.
%
% DESCRIPTION
%
%       'curvatureAnalysis_drive' is an example driver for a curvature
%       analysis run.
%       
%       Most of the bulk of this function is to finely specify sub-sections
%       of an entire analysis search space. When run serially over a whole
%       brain, the analysis can take >10 hours for both hemispheres and 
%       autodijk processing. The pattern of input arguments defines
%       subsections of this space suitable for parallel processing
%       in different MatLAB instances.
%       
% NOTE:
%
% HISTORY
% January 2010
% o Enhancements.
%
% May 2010
% o Parallelization (via Dan).
% 


    function    [C] = subregion_define(C, astr_lsArgs)
    %
    % DESC
    % Based on the <astr_lsArgs> and assuming that regions
    % are defined in the <analysisDir>/<annotFile>/ hierarchy,
    % define a region subset...
    % 
        str_pwd = pwd;
        str_aparcDir    = get(C, 'aparcDir');
        cd(str_aparcDir);
        c_ls    = ls09('-d', astr_lsArgs);
        for region=1:numel(c_ls)
            C = set(C, 'regionFilter', c_ls{region});
        end
        cd(str_pwd);
    end


    b_offScreenCentroids        = 1;
    b_subjLabelFileUse          = 0;
    cstr_surfaceSpec            = {'smoothwm'};
    b_plotLines                 = 1;
    b_plotHistograms            = 0;
    b_autodijk                  = 0;
    b_hemiFilter                = 0;
    b_regionFilter              = 0;
    b_subjFilter	        = 0;
    b_curvSpec                  = 0;
    str_subjSpec                = 'entire';
    str_hemi                    = 'rh';

    if length(varargin) >= 1
        verbosity               = varargin{1};
    end;
    if length(varargin) >= 2
        b_subjLabelFileUse      = varargin{2};
    end;
    if length(varargin) >= 3
        cstr_surfaceSpec        = varargin{3};
    end;
    if length(varargin) >= 4
        b_plotLines	        = varargin{4};
    end;
    if length(varargin) >= 5
        b_plotHistograms        = varargin{5};
    end;
        if length(varargin) >= 6
        b_autodijk	        = varargin{6};
    end;
    if length(varargin) >= 7
        b_hemiFilter    = 1;
        str_hemi        = varargin{7};
    end;
    if length(varargin) >= 8 
        b_subjFilter	= 1;
        str_subjSpec	= varargin{8};
    end
    if length(varargin) >= 9
        b_regionFilter  = 1;
        str_regionSpec  = varargin{9};
    end
    if length(varargin) >= 10
        b_curvSpec      = 1;
        cstr_curvSpec   = varargin{10};
    end

    C = curvature_analyze();

    C = set(C, 'verbosity',                     verbosity);
    C = set(C, 'annotFile',                     astr_annotFile);
    C = set(C, 'groupIDfile',                   astr_groupFileID);

    C = set(C, 'offScreenCentroidPlots',        b_offScreenCentroids);
    C = set(C, 'subjLabelFile_use',             b_subjLabelFileUse);
    C = set(C, 'surface',                       cstr_surfaceSpec);
    C = set(C, 'b_subjFilter',                  b_subjFilter);
    C = set(C, 'subjFilter',                    str_subjSpec);
    C = set(C, 'b_hemiFilter',                  b_hemiFilter);
    C = set(C, 'hemiFilter',                    str_hemi);
    C = set(C, 'usePlotLines',                  b_plotLines);
    C = set(C, 'b_curvFuncClear',               1);
    C = set(C, 'b_drawHistPlots',               b_plotHistograms);
    C = set(C, 'b_parcelFromLabelFile',         true);

    if b_plotHistograms
        C = set(C, 'b_lowerLimit',              1);
        C = set(C, 'f_lowerLimit',              -2.0);
        C = set(C, 'b_upperLimit',              1);
        C = set(C, 'f_upperLimit',              2.0);
    end

    if ~b_autodijk
        if ~b_curvSpec
            C = set(C, 'curvFuncFilter',    'K');
            C = set(C, 'curvFuncFilter',    'H');
            C = set(C, 'curvFuncFilter',    'K1');
            C = set(C, 'curvFuncFilter',    'K2');
            C = set(C, 'curvFuncFilter',    'S');
            C = set(C, 'curvFuncFilter',    'C');
            C = set(C, 'curvFuncFilter',    'BE');
            C = set(C, 'curvFuncFilter',    'thickness');
            C = set(C, 'b_lowerLimit',       1);
            C = set(C, 'b_upperLimit',       1);
        else
            for curv = 1:numel(cstr_curvSpec)
                C = set(C, 'curvFuncFilter',    cstr_curvSpec{curv});
            end
        end
        C = set(C, 'f_lowerLimit',       -30.0);
        C = set(C, 'f_upperLimit',       30.0);
    else
        if ~b_curvSpec
            C = set(C, 'curvFuncFilter',    'autodijk-K');
            C = set(C, 'curvFuncFilter',    'autodijk-H');
            C = set(C, 'curvFuncFilter',    'autodijk-K1');
            C = set(C, 'curvFuncFilter',    'autodijk-K2');
            C = set(C, 'curvFuncFilter',    'autodijk-S');
            C = set(C, 'curvFuncFilter',    'autodijk-BE');
        else
            for curv = 1:numel(cstr_curvSpec)
                str_autodijkCurv = sprintf('autodijk-%s', cstr_curvSpec{curv})
                C = set(C, 'curvFuncFilter',    str_autodijkCurv);
            end
        end
        C = set(C, 'b_lowerLimit',      0);
        C = set(C, 'b_upperLimit',      0);
    end
    C = set(C, 'b_curvaturesPostScale', 0);
    C = set(C, 'b_centroidLabelPlot',   1);

    if b_regionFilter
        C = set(C, 'b_regionFilter',    b_regionFilter);
        C = subregion_define(C, str_regionSpec);
    end

    str_dir     = pwd;
    fprintf(1, 'Running analysis in %s\n', str_dir);
    fprintf(1, 'Using groupID <%s>\n',  astr_groupFileID);

    C = run(C);
end
