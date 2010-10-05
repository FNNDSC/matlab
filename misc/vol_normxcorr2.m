function [V] = vol_normxcorr2(a_Vtemplate, aV)
%
% NAME
%
%       function [V] = vol_normxcorr2(a_Vtemplate, aV)
%
% ARGS
% INPUT
%       a_Vtemplate             vol                     volume template
%       aV                      vol                     source volume --
%                                                       should be larger
%                                                       than template for
%                                                       best results
% 
% DESC
%       Run each slice in a_Vtemplate and a_V through 'normxcorr2'.
% 
% PRECONDITIONS
%       o All volumes have the same number of slices
%       o In-plane-size(aV) >> In-plane-size(aV_template)
% 
% POSTCONDITIONS
%       o In-plane-size(V) > In-plane-size(aV)
%
% HISTORY
% 18 December 2008
% o Initial design and coding.
%

sz                      = size(aV);
correlatingSlices       = 0;

for slice   = 1:sz(3)
    M       = a_Vtemplate(:,:,slice);
    f_std   = std(M(:));
    f_cor   = 0.0;
    str_info = sprintf('\tCorrelating slice %04d/%04d, std = %f, ', ...
                        slice, sz(3), f_std);
        fprintf(1, str_info);
    if f_std
        V(:,:,slice)    = normxcorr2(a_Vtemplate(:,:,slice), aV(:,:,slice));
        f_cor           = max(max(V(:,:,slice)));
        correlatingSlices = correlatingSlices + 1;
    end
    str_cor     = sprintf('max correlation = %f     ', f_cor);
    fprintf(1, str_cor);
    str_info = sprintf('%s%s', str_info, str_cor);
    str_b   = '';
    for b=1:length(str_info),str_b = sprintf('%s%s', str_b, '\b'); end
    fprintf(1, str_b);
end
fprintf('\n');

if ~correlatingSlices
  V = zeros(size(a_Vtemplate));
end
