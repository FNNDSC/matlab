function C =	autodijk(varargin)
%
% NAME
%
%  function C =	autodijk()
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%
% DESCRIPTION
%
%	'autodijk' constructs the base class for analyzing the
%       Dijkstra-based properties of a curvature mapping on a 
%       FreeSurfer surface.
%
% NOTE:
%
% HISTORY
% 02 November 2009
% o Initial design and coding.
%


%
% class autodjik
%

% class internal data
C.mstr_obj			= 'autodijk';
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

%
% Input sources
C.mstr_workingDir               = pwd;          % root node of working dir
C.mstr_inputDir                 = pwd;
C.mstr_optionsFile              = 'options.txt';
C.mstr_curvatureFileName        = '';

%
% Run type
C.mstr_runType                  = 'polar';      % The analysis to perform.

%
% Output file
C.mstr_outputDir                = './';
C.mstr_outputFileName           = 'cost.crv';
C.mstr_outputTxtFile            = 'cost.crv.txt';
C.mfid_outputTxtFile            = 0;
C.mv_output                     = [];
C.mfnum                         = 0;

%
% Loop constructs and control flags
C.mb_imagesSave			= 0;		% If TRUE, save a set of
						% jpg images
C.mvertex_polar                 = 0;            % Polar vertex
C.mvertex_step                  = 1;            % Step increment
C.mvertex_start                 = 1;            % Start vertex
C.mvertex_end                   = 1;            % Typically set to 
                                                %+ numel(C.mv_output)-1
C.mb_endOverride                = 0;            % If FALSE, the <end> is set
                                                %+ to numel(C.mv_output)-1

%
% Misc output fields / display handles
C.m_LC                          = 50;           % left col margin
C.m_RC                          = 30;           % right col margin
C.mhFigure			= 0;

%
% Auxillary bash shell scripts
C.mscript_dsh                   = 'dsh';
C.mexec_backend                 = 'mris_pmake';

switch nargin
    case 0
	% No argument - set defaults
    case 1
	% 1 argument - if the arg is a basac_process object, copy to new object
	if (isa(varargin{1}, 'autodijk'))
	    C = varargin{1};
	end
end

C 	= class(C, 'autodijk');

