function [av] = vol_vectorize(aV, varargin)
%
% [aV] = vol_imshow(aV [, aV_mask = ones(aV)])
%
% ARGS
% INPUT
% aV                    volume                  volume data to vectorize
%
% OPTIONAL
% aV_mask               volume                  mask volume
% 
% DESC
% "Vectorizes" (i.e. reshapes) a volume into linear vector. If an optional
% <aV_mask> is provided, only process volume elements masked by non-zero
% in <aV_mask>. If no mask provided, process the whole input <aV>.
% 
% HISTORY
% 12 December 2008
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

v_sizeInput             = size(aV);
V_mask                  = ones(v_sizeInput);
aVmasked                = zeros(v_sizeInput);

if length(varargin) >= 1; V_mask        = varargin{1}; end

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
av              = aV(v_mask);

end