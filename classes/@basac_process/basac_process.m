function c =	basac_process(varargin)
%
% NAME
%
%  function c =	basac_process()
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%
% DESCRIPTION
%
%	'basac_process' constructs the base class for analyzing the
%       B0, ASL, and ADC volumes for correlations -- the name is a
%       somewhat tortured amalgamation of the underlying volumes:
%       basac -- B(0)AS(L)A(D)C
%
% NOTE:
%
% HISTORY
% 16 December 2008
% o Initial design and coding.
%

%
% class img2dicom
%

% class internal data
c.mstr_obj			= 'basac_process';
c.mstr_class			= 'unnamed';
c.mstack_proc			= stack();
c.m_verbosity			= 2;
%
% Source data structure
% All directory names should be absolute
%
c.mstr_asladcInputDir		= './';		% Dir containing the asl, adc
c.mstr_aslInputFile		= '';           % Normalized ASL input
c.mstr_adcInputFile             = '';           % Normalized ADC input
c.mstr_adcOrigFile              = '';           % Orig ASL (B0 masked) input
c.mstr_aslOrigFile              = '';           % Orig ADC (B0 masked) input

c.mstr_b0MaskInputDir           = './';         % Dir containing the b0 mask
c.mstr_b0MaskInputFile          = '';           % b0 mask file

c.mstr_analysisDir              = './';         % Dir that analysis output will
                                                %+ be written to.
%
% Run type
c.mstr_runType                  = 'default';    % The analysis to perform. By
                                                %+ setting the runType to 
                                                %+ 'self-adc' or 'self-asl'
                                                %+ an autocorrelation unit
                                                %+ test is performed.
                                                %+ This variable is typically
                                                %+ only set by a call to
                                                %+ basac_initialize(...)

%
% Image structures
c.mSMRI_ADC                     = {};           % ADC normalized structure
c.mSMRI_ASL                     = {};           % ASL normalized structure
c.mSMRI_ADCorig                 = {};           % ADC orig structure
c.mSMRI_ASLorig                 = {};           % ASL orig structure
c.mSMRI_B0                      = {};           % B0 structure

c.mVn_ADC                       = [];           % Normalized ADC volume
c.mVn_ADCcopy			= [];		% Copy of original ADC
c.mVn_ASL                       = [];           % Normalized ASL volume
c.mb_invASL                     = 1;            % Invert ASL volume?
c.mVinv_ASL                     = [];           % Normalized/"inverted" ASL 
c.mV_B0                         = [];           % B0 volume
c.mV_ASLB0                      = [];           % Original ASL masked volume
c.mV_ADCB0                      = [];           % Original ADC masked volume

%
% Analyzed data
c.mb_ADCsuppressCSF		=  1;		% Flag for suppressing CSF
c.mf_stdOffsetADCCSF		=  1.5;		% Offset for filtering ADC CSF
c.mf_stdOffsetADC               = -2.5;         % Offset for ADC std analysis
c.mf_stdOffsetASL               = -2.5;         % Offset for ASL std analysis
c.mV_ADCroiCSF			= [];		% Statistical CSF ROI in ADC
c.mV_ADCroi                     = [];           % Statistical ROI in ADC
c.mV_ASLroi                     = [];           % Statistical ROI in ASL
c.mV_ADCroiADCCSF		= [];		% ADC with CSF ROI overlay
c.mV_ADCroiADC			= [];		% ADC with ROI overlay
c.mV_ASLroiASL			= [];		% ASL with ROI overlay

c.mM_kernelADC                  = [7 7];        % Kernel size for median ADC 
						%+ filtering
c.mM_kernelASL                  = [11 11];      % Kernel size for median ASL 
						%+ filtering 
c.mV_ADCfiltCSF			= [];		% Filtered ADC CSF volume
c.mV_ADCfilt                    = [];           % Filtered ADC volume
c.mV_ASLfilt                    = [];           % Filtered ASL volume
c.mV_ADCfiltADC                 = [];           % ADC with filtered ADC overlay
c.mV_ASLfiltASL                 = [];           % ASL with filtered ASL overlay
c.mv_ADCfilt                    = [];           % Filtered ADC vectorized vol
c.mv_ASLfilt                    = [];           % Filtered ASL vectorized vol


c.mv_voxelSize                  = [1.0 1.0 1.0];% Voxel size, determined from
                                                % MRIread
c.m_ADCroiVoxels                = -1;           % Voxel count of ROI in ADC
c.m_ASLroiVoxels                = -1;           % Voxel count of ROI in ASL
c.mf_ADCroiVol                  = -1;           % Volume of ROI in ADC
c.mf_ASLroiVol                  = -1;           % Volume of ROI in ASL

c.stats_ADCnormF                = struct;       % The stats info on
c.stats_ADCnormNF               = struct;       %+ processed ADC volumes
c.stats_ADCorigF                = struct;       %+ norm: normalized
c.stats_ADCorigNF               = struct;       %+ orig: original
c.stats_ASLnormF                = struct;       % The stats info on
c.stats_ASLnormNF               = struct;       %+ processed ASL volumes
c.stats_ASLorigF                = struct;       %+ norm: normalized
c.stats_ASLorigNF               = struct;       %+ orig: original
                                                %+ F: ROI filtered
                                                %+ NF: non-ROI region
c.mf_ASLorigScale               = 1.0;          % Orig ASL scale factor
c.mf_ADCorigScale               = 1.0;          % Orig ADC scale factor

c.mV_ADClarge                   = [];           % The expanded ADC volume used
                                                %+ to contain the ASL volume
                                                %+ and processed to determine 
                                                %+ the correlation
                                                
                                                % Correlation volume will have
                                                %+ number of slices from 1 to
                                                %+ highest slice index that
                                                %+ showed non-zero correlation.                                                

                                                % Correlation vector will have
                                                %+ same number of slices as
                                                %+ input ASL/ADC volumes.

c.m_ROIfilterCount		= 1;		% Number of times to run the 
						%+ ROI statistical filters.
						%+ After each filter, an ROI is
						%+ selected, re-flushed with 
						%+ the masked mean, and re-
						%+ filtered. If this is set to
						%+ -1, then loop until
						%+ tolerance.
c.mf_meanMaskTolerance		= 0.001;	% If the ROIfilterCount is set
						%+ to -1, keep looping across
						%+ the ROI filter step until
						%+ successive f_meanMask values
						%+ are within tolerance. Note
						%+ that the loop is internally
						%+ hard limited if there is
						%+ no convergence.
c.mV_correlation                = [];           % Correlation volume
c.mv_maxCorrelationPerSlice     = [];           % Correlation vector containing
                                                %+ the maximum correlation
                                                %+ value for each slice in the
                                                %+ correlation volume
c.mstr_registrationPenalizeFunc	= 'sigmoid';	% Choices are either 'sigmoid'
						%+ or 'linear'.
c.mv_registrationOffset		= [];		% Registration error fraction
						%+ for correlated slices.
c.mv_maxCorrelationPerSliceR    = [];           % Raw max correlation per slice
c.mv_maxCorrelationPerSliceW	= [];		% Correlation weighed by
						%+ inverted fractional distance 
						%+ between centroids of images. 
						%+ This means that two images 
						%+ that have a large offset
						%+ between centroids are 
						%+ penalized. The closer the
						%+ positional overlap, the 
						%+ better. 
c.mv_maxCorrelation             = [];           % Correlation vector comprising
                                                %+ only non-zero max 
                                                %+ correlation values
c.mf_meanCorrelation            = 0.0;          % Mean of mv_maxCorrelation
c.mf_integralCorrelation        = 0.0;          % The integration of the
                                                %+ correlation vector
c.mf_meanIntegralCorrelation    = 0.0;          % The mean integral

%
% Loop constructs and control flags
c.mb_showVolumes                = 1;		% vol_imshow() main volumes
c.mb_showScatter                = 1;            % Show scatter plot
c.mb_showMaxCorrelation         = 1;            % Show max correlation vector
c.mb_imagesSave			= 0;		% If TRUE, save a set of
						% jpg images 
c.mb_binarizeMasks              = 1;            % Boolean flag: if true,
                                                %+ binarize the ASL and ADC
                                                %+ filter masks. This improves
                                                %+ inter-subject comparisons
                                                %+ since volume intensities are
                                                %+ reduced to 1 and 0.
c.mb_registrationPenalize       = 1;            % Boolean flag for penalizing
                                                %+ "bad" registrations.
c.mb_pulseFiter                 = 1;            % Control flag for applying
                                                %+ pulse filter on the
                                                %+ max correlation per slice
                                                %+ vector.
c.mb_filterOnRawROI             = 0;            % If TRUE, filter ASL and ADC
                                                %+ volumes on initial ROI 
                                                %+ selection and not the 
                                                %+ smoothed filter. Used by
                                                %+ the ROI_volsMeasure
                                                %+ method.
%
% Source data info
% The 'Base' directories are fixed relative to a given SUBJECTS_DIR
c.mstr_workingDir		= pwd;		% root node of working dir

%
% Misc output fields / display handles
c.m_marginLeft			= 45;
c.m_marginRight			= 35;
c.mhFigure			= 0;

%
% Auxillary bash shell scripts
c.mscript_nameme	        = 'void.sh';

switch nargin
    case 0
	% No argument - set defaults
    case 1
	% 1 argument - if the arg is a basac_process object, copy to new object
	if (isa(varargin{1}, 'basac_process'))
	    c = varargin{1};
	end
end

c 	= class(c, 'basac_process');

