function c =	img2dicom(varargin)
%
% NAME
%
%  function c =	img2dicom()
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%
% DESCRIPTION
%
%	'img2dicom' constructs the base class for converting arbitrary
%	images to dicom format
%
% NOTE:
%
% HISTORY
% 03 April 2008
% o Initial design and coding.
%

%
% class img2dicom
%
% class internal data
c.mstr_obj			= 'img2dicom';
c.mstr_class			= 'unnamed';
c.mstack_proc			= stack();
c.mstr				= '';
c.m_verbosity			= 1;
%
% Source data structure
% All directory names should be absolute
%
c.mstr_imgInputDir		= './';		% Dir containing the processed
						%+ images (based on input
						%+ dicoms)
c.mstr_imgInputFile		= '';

c.mstr_dicomInputDir		= './';		% Dir containing the original
						%+ dicom series
c.mstr_dicomInputFile		= '';		% File in the dicom series

c.mstr_dicomOutputDir		= './';		% Dir containing the converted
						%+ dicom series
c.mstr_dicomOutputFile		= '';		% File in the converted dicom 
						%+ series

c.mb_newSeries			= 0;		% Create a new series?
c.m_SeriesInstanceUID		= 0;		% New SeriesInstanceUID
c.m_SeriesNumber		= 0;		% New SeriesNumber
c.mstr_SeriesDescription	= 'Track_vis_'; % Series description field
%
% Dicom header info
c.mDicomInfo			= 0;

%
% Image cells
c.mcell_img			= cell(0);	% Cell arrays to store input/
c.mcell_dcm			= cell(0);	%+ output images.
c.mcell_imgFileName		= cell(0);	% Track the image filenames
%
% Loop constructs and control flags
c.mb_visuals			= 1;		% Toggle to 0 to turn off
						% all visualizations.
c.mb_imagesSave			= 0;		% If TRUE, save a set of
						% jpg images of each COR 
						% slab with cortical slices.
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
c.mscript_sulcusList	= 'sulclist.sh';

switch nargin
    case 0
	% No argument - set defaults
    case 1
	% 1 argument - if the arg is an img2dicom object, copy to new object
	if (isa(varargin{1}, 'img2dicom'))
	    c = varargin{1};
	end
end

c 	= class(c, 'img2dicom');

