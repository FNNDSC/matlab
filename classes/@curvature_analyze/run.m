function C = run(C, varargin)
%
% NAME
%
%  function C = run(C)
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze  class
%
% OPTIONAL
%
% OUTPUT
%	C		class		curvature_analyze class
%	
%
% DESCRIPTION
%
%	This method is the main entry point to "running" a curvature_analyze
%	class instance. It controls the main processing loop, viz. 
%
%               - populating internal subject info cell array
%               - creating the main data map that holds curvatures and processed
%                 information
%
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%
% POSTCONDITIONS
%
%
% NOTE:
%
% HISTORY
% 18 September 2009
% o Initial design and coding.
%

% Use global array rather than class members because then the data
% does not need to be copied when calling class member functions.  This
% was strictly for performance reasons.
global g_arr_data;
g_arr_data   = {};

C.mstack_proc 	= push(C.mstack_proc, 'run');

%
% Initializations... (subjects_preprocess also calls 'annotation_parse(...)')
csys_printf(C, 'Preprocessing subjects...\n');
C               = subjects_preprocess(C);
csys_printf(C, 'Constructing internals...\n');
C               = internals_build(C);

%
% Read in core data...
csys_printf(C, 'Reading curvatures...\n');
C               = map_curvaturesRead(C);
csys_printf(C, 'Reading annotations...\n');
C               = map_annotationsRead(C);

%
% Perform the parcellations...
csys_printf(C, 'Parcellating curvatures...\n');
C               = map_curvaturesParcellate(C);

%
% At this point, all the curvatures for the whole data structure
% are defined. We can now perform the analysis on all regions.
csys_printf(C, 'Processing histograms...\n');
C               = map_histogramsProcess(C);
if(C.mb_drawHistPlots)
    csys_printf(C, 'Plotting histograms...\n');
    C           = map_histogramsPlot(C);
else    
    csys_printf(C, 'Processing curvature stats...\n');
    C               = map_statsProcess(C);
    csys_printf(C, 'Calculating centroids of histograms...\n');
    C               = map_centroidsProcess(C);

    if C.mb_perSubjCentroidsPlot
        csys_printf(C, 'Plotting/Saving centroids of histograms...\n');
        C               = map_centroidsPlot(C);
    end

    csys_printf(C, 'Analyzing/Saving centroids of histograms...\n');
    C               = map_centroidsAnalyze(C);

    csys_printf(C, 'Point spread plotting centroids of histograms...\n');
    C               = map_centroidsPointSpread(C);
end

csys_printf(C, 'Shutting down...\n');

[C.mstack_proc, element] = pop(C.mstack_proc);
end
