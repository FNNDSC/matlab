function [aV] = vol_medfilt2(aV_input, varargin)
%
% function [aV] = vol_medfilt2(aV_input [,aM_kernel, aV_mask])
%
% ARGS
% INPUT
% a_V			vol                     volume data to imadjust
% 
% DESC
%       Run each (possibly masked) slice in aV_input through a median
%       filter.
%
% HISTORY
% 16 December 2008
% o Initial design and coding.
%

%%%%%%%%%%%%%%
%%% Nested functions
%%%%%%%%%%%%%%
        function error_exit(    str_action, str_msg, str_ret)
                fprintf(1, '\tFATAL:\n');
                fprintf(1, '\tSorry, some error has occurred.\n');
                fprintf(1, '\tWhile %s,\n', str_action);
                fprintf(1, '\t%s\n', str_msg);
                error(str_ret);
        end

        function vprintf(level, str_msg)
            if verbosity >= level
                fprintf(1, str_msg);
            end
        end
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%

M_kernel                = [3 3];
v_sizeInput             = size(aV_input);
V_mask                  = ones(v_sizeInput);
aVmasked                = zeros(v_sizeInput);

if length(varargin) >= 1; M_kernel      = varargin{1}; end
if length(varargin) >= 2; V_mask        = varargin{2}; end

v_sizeMask              = size(V_mask);
if v_sizeMask ~= v_sizeInput
    error_exit('checking volumes', 'mask and input volumes mismatch.', '1');
end
if length(v_sizeInput) ~= 3
    error_exit( 'examining input data',                         ...
                'data does not seem to be a volume',            ...
                '1');
end

v_mask          = find(V_mask > 0);
aVmasked(v_mask)= aV_input(v_mask);

V       = aV_input;
sz      = size(V);

for slice   = 1:sz(3)
    aV(:,:,slice)    = medfilt2(aVmasked(:,:,slice), M_kernel);
end

end