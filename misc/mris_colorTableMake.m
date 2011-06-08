function [aC_indicesROI, aC_indicesNROI] =              ...
                                  mris_circleROI(       ...  
                                        astr_mrisFile,  ...
                                        av_center,      ...
                                        af_radius,      ...
                                        varargin)
%
% NAME
%  function [aC_indicesROI, aC_indicesNROI] =              ...
%                                    mris_circleROI(       ...  
%                                          astr_mrisFile,  ...
%                                          av_center,      ...
%                                          af_radius      ...
%                                          [, aS_colorTable, astr_annotFile)
%
% $Id:$
%
%
% ARGUMENTS
%       
%       INPUT
%       astr_mrisFile   string          filename of surface file to load
%       av_center       vector          list of vertex indices about which
%                                       to determine ROIs.
%       af_radius       float           radius length
%
%       OPTIONAL
%       aS_colorTable   struct          color table
%       astr_annotFile  string          annotation file name
%
%       OUTPUT
%       aCv_indicesROI  cell            indices within the ROI 
%       aCv_indicesNROI cell            indices outside the ROI
%
% DESCRIPTION
%
%       'mris_circleROI' accepts a list of vertex points and
%       generates circular ROIs about each point. The vertex indices
%       are returned as cell arrays with ROIs and non-ROIs.
%       
%       If an optional colortable and output filename are provided,
%       the ROIs are added to a FreeSurfer annotation file suitable
%       for uploading onto surfaces.
%       
% PRECONDITIONS
%       o <astr_mris> and <aS_colorTable> should be valid.
%       o FreeSurfer environment.
%
% POSTCONDITIONS
%       o Vertex indices are returned and optional annotation file
%         is created.
%         
% SEE ALSO
%       o read_annotation / write_annotation for a description of the
%         color table format.
%
% HISTORY
% 06 June 2011
% o Initial design and coding.
%

% ---------------------------------------------------------

sys_printf('mris_circleROI: START\n');
 

b_annotate      = 0;
% Parse optional arguments
if length(varargin) == 2, 
    b_annotate          = 1;
    S_ct                = varargin{1};
    str_annotationFile  = varargin{2};
end

% Read surface
colprintf('40;40', 'Reading mris file', '[ %s ]\n', astr_mrisFile);
[v_vertices, v_faces] = read_surf(astr_mrisFile);
v_vertSize      = size(v_vertices);
v_faceSize      = size(v_faces);
str_vertSize    = sprintf('%d x %d', v_vertSize(1), v_vertSize(2));
str_faceSize    = sprintf('%d x %d', v_faceSize(1), v_faceSize(2));
colprintf('40;40', 'Size of vert struct', '[ %s ]\n', str_vertSize);
colprintf('40;40', 'Size of face struct', '[ %s ]\n', str_faceSize);

numROIcenters   = numel(av_center)

if numROIcenters
    aC_indicesROI       = cell(1, numROIcenters)
    ac_indicesNROI      = cell(1, numROIcenters)
    for vi = 1:length(v_vertices)
        for ROI=1:numROIcenters
            v_ROIcenter = v_vertices(av_center(ROI), :);
            f_dist      = norm(v_vertices(vi, :) - v_ROIcenter);
            if (dist < af_radius)
                ac_indicesROI{ROI}
            end
        end
    end
end


colprintf('40;40', 'Writing label', '');
write_label(v_index, av_vertices, v_labelVals, astr_labelFile);
colprintf('40;40', '', '[ %s ]\n', astr_labelFile);

sys_printf('mris_circleROI: END\n');

end
% ---------------------------------------------------------


