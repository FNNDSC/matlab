function [av_curvFiltered, av_vertices, av_curvOrig] =  ...
                                  mris_curvToLabel(     ...  
                                        astr_mrisFile,  ...
                                        astr_curvFile,  ...
                                        astr_labelFile, ...
                                        varargin)
%
% NAME
% function [av_curvFiltered, av_vertices, av_curvOrig] =... 
%                                   mris_curvToLabel(   ...
%                                        astr_mrisFile, ...
%                                        astr_curvFile, ...
%                                        astr_labelFile,...
%                                        varargin)
%
% $Id:$
%
%
% ARGUMENTS
%       
%       INPUT
%       astr_mrisFile   string          filename of surface file to load
%       astr_curvFile   string          filename of curvature file to load
%       astr_labelFile  string          filename of label file to create
%
%       OPTIONAL
%       hf_filter       handle          handle to anonymous function that is
%                                       passed to a 'find' on the curvature
%                                       vector. Filtered output is used to
%                                       specify the vertices that constitute
%                                       the label.
%
%       OUTPUT
%       av_curvFiltered vector (nx1)    curvature vector used to create label.
%       av_vertices     vector (nx3)    (x,y,z) of corresponding vertices on
%                                       surface file.
%       av_curvOrig     vector (nx1)    unfiltered curvature vector as read 
%                                       from file.                                
%
% DESCRIPTION
%
%       'mris_curvToLabel' simply uses a curvature file and an optional
%       filter function handle to create a FS label file.
%       
% PRECONDITIONS
%       o <astr_mris> and <astr_curv> should be valid filenames.
%       o FreeSurfer environment.
%
% POSTCONDITIONS
%       o Label file is created
%
% HISTORY
% 05 June 2011
% o Initial design and coding.
%

% ---------------------------------------------------------

sys_printf('mris_curvToLabel: START\n');
 

h_filter        = 0;
b_filter        = 0;
% Parse optional arguments
if length(varargin) >= 1, 
    b_filter    = 1;
    h_filter    = varargin{1};       
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

% Read curvature file
colprintf('40;40', 'Reading curvature file', '[ %s ]\n', astr_curvFile);
[v_curv, fnum] = read_curv(astr_curvFile);
colprintf('40;40', 'Number of curv elements', '[ %d ]\n', numel(v_curv));
av_curvOrig     = v_curv;

if numel(v_curv) ~= v_vertSize(1)
    error_exit( 'reading inputs',        ...
                'mismatch between curvature size and surf vertices', ...
                '1');
end

v_vertices      = single(v_vertices);
v_faces         = int32(v_faces+1);  % for matlab compliance

if b_filter
    av_curvFiltered     = v_curv(find(h_filter(v_curv)));
    v_index             = find(h_filter(v_curv));
    colprintf('40;40', 'Applying handle filter', '[ %s ]\n',    ...
                strtrim(evalc('disp(h_filter)')));
else
    av_curvFiltered     = v_curv;
    v_index             = [1:numel(v_curv)];
end
av_vertices     = v_vertices(v_index,:);
v_labelVals     = zeros(length(v_index), 1);

colprintf('40;40',      ...
    'Number of vertices that satisfy filter', '[ %d ]\n',       ...
    numel(v_index));

colprintf('40;40', 'Writing label', '');
write_label(v_index, av_vertices, v_labelVals, astr_labelFile);
colprintf('40;40', '', '[ %s ]\n', astr_labelFile);

sys_printf('mris_curvToLabel: END\n');

end
% ---------------------------------------------------------


