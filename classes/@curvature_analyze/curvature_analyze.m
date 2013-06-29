function C =	curvature_analyze(varargin)
%
% NAME
%
%  function C =	curvature_analyze()
%       $Id: curvature_analyze.m 469 2011-06-15 19:34:06Z rudolphpienaar $
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%
% DESCRIPTION
%
%	'curvature_analyze' constructs the base class for analyzing the
%       curvature properties of a series of FreeSurfer processed subjects.
%
% NOTE:
%
% HISTORY
% 18 September 2009
% o Initial design and coding.
%

%
% System "global" variable declaration
%
% The g_arr_data is an array of cells of length equal to the entire problem
% space, i.e. hemi * curvFunc * subjects * regions * surface type. Each 
% element of the array is a cell of length equal to the core data components.
% This array is essentially a "flattened" representation of what originally
% was a map tree to hold all the relevant data, and which was originally
% part of the basic system class definition. It is removed from the class
% here for performance / parallelization reasons.
g_arr_data                      = {};

%
% class curvature_analyze
%

% class internal data
C.mstr_obj			= 'curvature_analyze';
C.mstr_class			= 'unnamed';
C.mstack_proc			= stack();
C.m_verbosityLevel              = 1;            % Individual methods change
C.m_verbosity                   = 9;            % verbosityLevel. Catch all
                                                % messages by setting high
                                                % verbosity. Catch only syslog
                                                % messages by setting 
                                                % 'verbosity = 1'
%
% Source data structure
%
% General data organized according to subject.
C.mstr_lsSubjArgs               = '[0-9]*';     % ls args for tagging subject
                                                %+ dir names.
C.mb_subjLabelFile_use          = 1;            % the 'subjLabelFile' allows 
                                                % for user-spec'd labels for
                                                % each subject. If this is
                                                % false, the system will label
                                                % each subject with its
                                                % filesystem dir name
C.ms_info                       = struct;
C.ms_info.mstr_subjDir          = './';
C.ms_info.mstr_subjName         = '-x';
C.ms_info.mstr_subjLabel        = '';
C.ms_info.mstr_processDir       = 'curvAnalysis';
C.ms_info.mstr_workingDir       = '-x';
C.ms_info.mstr_idFile           = 'groupID.txt';
C.ms_info.mstr_subjLabelFile    = 'subjLabel.txt';
C.ms_info.muid                  = 0;
C.ms_info.mgid                  = 0;
C.ms_info.mv_voxelSize          = [ 1 1 1];
C.ms_info.mstr_voxelFile        = 'voxelSize.txt';
C.ms_info.mf_linearScaleFactor  = 1.0;          % Curvature postscale factor
C.ms_info.mf_surfaceScaleFactor = 1.0;          % Curvature postscale factor

%
% Curvature filename data
C.mstr_curvFSDir                = 'surf';       % Directory in FS tree that
C.mstr_curvFilePostfix          = 'crv';        %+ contains surfaces/curvs

%
% Cortical parcellation annotation data
C.mb_regionFilter               = 0;
C.mcstr_regionFilter            = { 'entire' };
C.ms_annotation                 = struct;
C.ms_annotation.mstr_labelDir   = 'label';
C.ms_annotation.mstr_annotFile  = 'aparc.annot';
C.ms_annotation.msAnnotation    = struct;
C.ms_annotation.mv_label        = [];
C.ms_annotation.mv_list         = [];
C.mb_parcelFromLabelFile        = 0;            % If true, generate the parcel
                                                %+ from the label file, and not
                                                %+ the annotation. This is only
                                                %+ useful if the label packed
                                                %+ in the annotation differs
                                                %+ from the original label --
                                                %+ only really a case in the
                                                %+ border overlap analysis.

%
% Core map structural components
C.mcstr_brainHemi               = {'rh', 'lh'};
C.mcstr_curvFunc                = { 'K', 'H', 'K1', 'K2', 'S', 'C', 'thickness' };
C.mc_subjectInfo                = {};
C.mmap_subjectInfo              = containers.Map;
C.mcstr_brainRegion             = {'entire'};
C.mcstr_brainRegionSkip		= {'unknown', 'corpuscallosum', 'cingulate', 'insula'};	
                                                % List of regions to skip in
						%+ the analysis
C.mb_brainRegionSkip		= 1;		% Flag controlling whether to
						%+ skip or not
				  
C.mcstr_surfaceType             = {'smoothwm'};
C.mcstr_coreData                = { 'histogram', 'curvature', 'centroid', ...
                                    'stats', 'axis', 'annotation' };
C.arr_process                   = {};               % Array of strings to process
C.mi_indexHistogram             = 1;                % Histogram index "enum" 
C.mi_indexCurvature             = 2;                % Curvature index "enum"
C.mi_indexCentroid              = 3;                % Centroid index "enum"
C.mi_indexStats                 = 4;                % Stats index "enum"
C.mi_indexAxis                  = 5;                % Axis index "enum"
C.mi_indexAnnotation            = 6;                % Annotation index "enum"
C.mi_indexCount                 = 6;                % !!IMPORTANT:!! Update
                                                    %+ this if you add new index
C.arr_processCount              = 0;                % Number of items to process
C.mmap_indexCache               = containers.Map;   % map full string back to
                                                    %+ index
C.arr_processSubjIndex          = 0;                % index lookup for 
                                                    %+ map_processSubj order
C.mb_mapDefined                 = 0;

%
% Additional structural components
%% Leaf node stats
C.ms_stats                      = struct;
C.ms_stats.l                    = -1;           % less than zero
C.ms_stats.z                    = -1;           % zero
C.ms_stats.g                    = -1;           % greater than zero
C.ms_stats.v_l                  = [];
C.ms_stats.v_z                  = [];
C.ms_stats.v_g                  = [];
C.ms_stats.f_absav              = 0.0;
C.ms_stats.f_absstd             = 0.0;
C.ms_stats.f_av                 = 0.0;
C.ms_stats.f_std                = 0.0;
C.ms_stats.f_pav                = 0.0;
C.ms_stats.f_pstd               = 0.0;
C.ms_stats.f_nav                = 0.0;
C.ms_stats.f_nstd               = 0.0;

%% Leaf node centroid
C.ms_centroid                   = struct;
C.ms_centroid.xn                = 0.0;
C.ms_centroid.yn                = 0.0;
C.ms_centroid.xp                = 0.0;
C.ms_centroid.yp                = 0.0;
C.ms_centroid.xc                = 0.0;
C.ms_centroid.yc                = 0.0;
C.ms_centroid.skewness          = 0.0;
C.ms_centroid.kurtosis          = 0.0;

%
% General data organized according to curvature types
C.mstr_analysisDir              = 'groupCurvAnalysis';
C.mstr_analysisPath             = '-x';
                                                % Analysis for whole
                                                %+ subj group
C.mstr_subjectsDir              = './';         % Subject's dir for analysis

%
% Run type
C.mstr_runType                  = 'default';    % The analysis to perform.

%
% Initial histogram analysis
C.mb_sulcCurv                   = 0;            % If TRUE, process
                                                %+ '?h.curv' and '?h.sulc'
                                                %+ files as well.
C.mb_curvaturesPostScale        = 1;            % If TRUE, apply scale factors
                                                %+ to curvatures
C.m_histBins                    = 1000;         % Histogram bins
C.mb_histNormalize              = 1;            % Normalize histogram?
C.mb_lowerLimitSet              = 1;            % Is lower limit set?
C.mf_lowerLimit                 = -1.5;         % Lower curvature limit
C.mb_upperLimitSet              = 1;            % Is upper limit set?
C.mf_upperLimit                 = 1.5;          % Upper curvature limit
C.mb_drawHistPlots              = 0;            % Plot (and save eps/jpg)?
C.mb_drawCumulativeHistPlots    = 0;            % Add all histograms to a single
                                                % plot. Useful only for smallish
                                                % number of subjects.
C.mb_animateHistPlots           = 0;            % Layout setting 
                                                %+ (pseudo animate)
C.mb_perSubjCentroidsPlot       = 1;            % Plot per-subject centroids
                                                %+ This is a once-off
                                                %+ and only needs to be run 
                                                %+ ONCE for each run session
C.mb_offScreenCentroidPlots     = 0;            % Visibility flag for on-screen
                                                %+ rendering of centroid plots.
                                                %+ These can take a long to 
                                                %+ render, so at times it's 
                                                %+ good to turn this flag ON
                                                %+ so that plots are generated
                                                %+ offScreen.
C.mb_yMinMax                    = 1;            % If TRUE, constrain y-values
                                                %+ for historgram between
C.mf_ymin                       = 0.0;          %+ ymin and
C.mf_ymax                       = 0.0;          %+ ymax.
C.mcell_table                   = {};           % Cell structure containing
                                                %+ individual table cell 
                                                %+ matrices.
C.mcell_hist                    = {};           % Histogram data for each
                                                %+ curv processed.


%
% Image structures

%
% Analyzed data

%
% Loop constructs and control flags
C.mb_imagesSave			= 0;		% If TRUE, save a set of
						% jpg images 
C.mb_centroidLabelPlot          = 1;            % if TRUE, add subject label
                                                %+ to each centroid plot

%
% Colors for plots
C.mc_lineStyle                   = { '-r+', '-yd', '-og', '-*b', '-cx', '-ms', '-k^' };
C.mc_pointStyle                  = { 'r+', 'yd', 'og', '*b', 'cx', 'ms', 'k^' };
C.mc_colorSpec                   = { 'r', 'y', 'g', 'b', 'c', 'm', 'k' };
C.mb_useLines                    = 0;

%
% Source data info
% The 'Base' directories are fixed relative to a given SUBJECTS_DIR
C.mstr_workingDir		= pwd;		% root node of working dir

%
% Misc output fields / display handles
C.m_LC                          = 80;           % left col margin
C.m_RC                          = 30;           % right col margin
C.mhFigure			= 0;

%
% Auxillary bash shell scripts
C.mscript_nameme	        = 'void.sh';

switch nargin
    case 0
	% No argument - set defaults
    case 1
	% 1 argument - if the arg is a basac_process object, copy to new object
	if (isa(varargin{1}, 'curvature_analyze'))
	    C = varargin{1};
	end
end

C 	= class(C, 'curvature_analyze');

