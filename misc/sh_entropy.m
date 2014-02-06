function [e] = sh_entropy(data, bins)

%
% Shannon entropy (in bits)
%
% Written: April 3, 2002 (lzollei)
%

if ~exist('bins')
 bins = 32;
end

[h, centers] = hist(data(:),bins);
count = length(data(:));
p = h/count;

% to get rid of the 0-count bins
nzero_ind = find(p);
p_short = p(nzero_ind);

e = - sum(p_short .* log2(p_short));

