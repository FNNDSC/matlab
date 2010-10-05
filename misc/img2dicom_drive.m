function [c] =	img2dicom_drive(varargin)
%
% NAME
%
%  function [c] =	img2dicom_drive()
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%
% OUTPUTS
%
% DESCRIPTION
%
%	'img2dicom_drive' "drives" an image-to-dicom conversion process. It 
%	provides a convenient entry point to starting and initializing an
%	img2dicom class.
%
% PRECONDITIONS
%
%	o None
%
% POSTCONDITIONS
%
%	o A debugging run through the img2dicom class is performed.
%
% NOTE:
%
% HISTORY
% 10 April 2008
% o Initial design and coding.
%
%

cell_plane	= {'SAG', 'COR', 'AXI'};

%%%%%%%%%%%%%% 
%%% Nested functions :START
%%%%%%%%%%%%%% 
    function error_exit(	str_action, str_msg, str_ret)
	fprintf(1, '\tFATAL:\n');
	fprintf(1, '\tSorry, some error has occurred.\n');
	fprintf(1, '\tWhile %s,\n', str_action);
	fprintf(1, '\t%s\n', str_msg);
	error(str_ret);
    end

    function [num] = SeriesNumber_set(astr_plane)
	num = -1;
	switch astr_plane
	    case 'SAG'
		num = 1000;
	    case 'COR'
		num = 1001;
	    case 'AXI'
		num = 1002;
	end
    end

%%%%%%%%%%%%%% 
%%% Nested functions :END
%%%%%%%%%%%%%% 

c	= img2dicom();

if length(varargin)
	str_plane	= varargin{1};
	cell_plane	= { str_plane };
end

for i=1:length(cell_plane)
    str_inputDir	= sprintf('./stage-3-tractSlice/%s', cell_plane{i});
    str_description	= sprintf('Track_vis_%s', cell_plane{i});
    c	= set(c,'verbosity',		10,				...
		'dicomInputDir', 	'./stage-1-dicomInput',		...
		'imgInputDir',		str_inputDir,			...
		'dicomOutputDir',	'./stage-4-dicomOutput',	...
		'SeriesDescription',	str_description,		...
		'SeriesNumber',		SeriesNumber_set(cell_plane{i}),...
		'b_newSeries',		1);
    c	= run(c);
end

end
