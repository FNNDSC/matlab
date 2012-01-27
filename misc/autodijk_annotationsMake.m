function [] = autodijk_annotationsMake(astr_base, varargin)
%
% NAME
% function [] = autodijk_annotationsMake(astr_base, [cstr_hemi, cstr_space])
%
% $Id:$
%
%
% ARGUMENTS
%       
%       INPUT
%       astr_base		string			one of 'PMG' or 'CHB' 
%       						or related tag for 
%       						first part of base 
%       						reference registration.
%       						If 'noreg' then will not
%       						use the registered
%       						sphere, but the
%       						original.
%       						
%
%       OPTIONAL
%       cstr_hemi		cell string		hemispheres to process
%       cstr_space		cell string		space to process
%
%       OUTPUT
%
% DESCRIPTION
%
%       'autodijk_annotationsMake' is a "driver" type script that
%       generates a set of annotation files for regions underpinning
%       an autodijk analysis.
%       
%       See the PRECONDITIONS for the list of (rather hardcoded)
%       requirements.
%              
% PRECONDITIONS
%       o FreeSurfer environment.
%       o <hemi>.sphere.roi_indices_{native&resampled}.mat
%
% POSTCONDITIONS
%       o An annotation file defining labeled regions is generated
%         for each set of center coordinates (defined in the *mat 
%         files).
%         
% SEE ALSO
%       o read_annotation / write_annotation for a description of the
%         color table format.
%
% HISTORY
% 13 June 2011
% o Initial design and coding.
%
% 20 June 2011
% o cstr_space = {'nativenoreg', 'resamplednoreg'}
%

% ---------------------------------------------------------

sys_printf('autodijk_annotationsMake: START\n');
 
[ret cstr_surfLst] = c_shell('find . -iname surf');

cstr_space  = {'native', 'resampled'};
cstr_hemi   = {'rh', 'lh'};
if length(varargin)>=1,	cstr_hemi	= varargin{1}; 	end
if length(varargin)>=2,	cstr_space	= varargin{2}; 	end

if strcmp(astr_base, 'noreg')
    str_mrisFile        = sprintf('sphere');
    str_registered      = 'noreg';
else
    str_mrisFile        = sprintf('sphere.to_%s01.reg', astr_base);
    str_registered      = 'reg';
end

str_topdir      = pwd;
for str_dir = cstr_surfLst
    str_dir = str_dir{1};
    str_line = repmat('_', [1, 80]);
    fprintf('%s\n', str_line);
    colprintf('40;40', 'Entering directory', '[ %s ]\n', str_dir);
    try
        cd(str_dir)
    catch ME
        error_exit('accessing "surf" directory',        ...
                    'no directory found', '10');
    end
    for str_hemi = cstr_hemi
        str_hemi = str_hemi{1};
        colprintf('40;40', 'Processing hemisphere', '[ %s ]\n', str_hemi);
        for str_space = cstr_space
            str_space = str_space{1};
            colprintf('40;40', 'Processing space', '[ %s ]\n', str_space);
            [ret cstr_mat]  = c_shell(sprintf('ls -1 %s*%s.mat', str_hemi, str_space));
            s_center    = load(cstr_mat{1});
            v_center    = s_center.indices;
            if strcmp(str_space, 'resampled')
                str_mrisFile    = sprintf('%s.resampled', str_mrisFile);
            end
            f_radius            = 100.0 * sin(deg2rad(45)) / sin(deg2rad(67.5));
            str_annotFile       = sprintf('regions-%s-%s.annot', str_registered, str_space);
            [Cv_indicesROI, Cv_indicesNROI, Cv_tracker, S_ct] = ...
                mris_circleROI( str_hemi,       ...
                                str_mrisFile,   ...
                                v_center,       ...
                                f_radius,       ...
                                str_annotFile,  ...
                                [str_space '_'], ...
                                1);       
        end
    end
    cd(str_topdir);
    fprintf('%s\n', str_line);
end

sys_printf('autodijk_annotationsMake: END\n');

end
% ---------------------------------------------------------


