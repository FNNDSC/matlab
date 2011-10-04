function c =	dcm_anonymize(varargin)
%
% NAME
%
%  function c =	dcm_anonymize()
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%
% DESCRIPTION
%
%	'dcm_anonymize' constructs the base class for implementing
%	a dicom anonymizer.
%
% NOTE:
%
% HISTORY
% 20 March 2009
% o Initial design and coding.
%

%
% class img2dicom
%
% class internal data
c.mstr_obj			= 'dcm_anonymize';
c.mstr_class			= 'unnamed';
c.mstack_proc			= stack();
c.mstr				= '';
c.m_verbosity			= 1;
%
% Source data structure
% All directory names should be absolute
%
c.mstr_dicomInputDir		= './';		% Dir containing the original
						%+ dicom series
c.mstr_dicomInputFile		= '';		% File in the dicom series

c.mstr_dicomOutputDir		= './';		% Dir containing the converted
						%+ dicom series
c.mstr_dicomOutputFile		= '';		% File in the converted dicom 
						%+ series

c.mstr_dirArg			= '*.dcm';	% Directory listing arguments
c.s_dicomFiles			= {};		% Structure containing all the
						%+ dicom files.
c.c_keep			= {
    'PatientAge', 
    'PatientSex',
    'StudyDescription',
    'SeriesDescription',
    'ProtocolName',
    'SeriesNumber'
				    };		% 'Keep' list
c.s_updateDicomInfo		= {};		% 'Update' structure

c.mb_newSeries			= 0;		% Create a new series?
c.m_SeriesInstanceUID		= 0;		% New SeriesInstanceUID
c.m_SeriesNumber		= 0;		% New SeriesNumber
c.mstr_SeriesDescription	= 'anon';	% Series description field
c.mstr_anonPrefix		= 'anon';	% Ouptut file prefix
%
% Dicom header info
c.mDicomInfo			= 0;

%
% Loop constructs and control flags
c.mb_visuals			= 1;		% Toggle to 0 to turn off
						% all visualizations.
c.mb_imagesSave			= 0;		% If TRUE, save a set of
						% jpg images of each COR 
						% slab with cortical slices.

%
% Misc output fields / display handles
c.mstr_workingDir		= pwd;		% root node of working dir
c.m_marginLeft			= 45;
c.m_marginRight			= 35;
c.mhFigure			= 0;

%
% Auxillary bash shell scripts
c.mscript_selfWrap		= 'dcm_anonymize.bash';

switch nargin
    case 0
	% No argument - set defaults
    case 1
	% 1 argument - if the arg is an img2dicom object, copy to new object
	if (isa(varargin{1}, 'dcm_anonymize'))
	    c = varargin{1};
	end
end

c 	= class(c, 'dcm_anonymize');

