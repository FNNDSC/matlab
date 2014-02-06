function [je,pdf] = sh_j_entropy(data1, data2, bins1, bins2)

%
% Shannon joint entropy (in bits)
%
% Written: April 3, 2002 (lzollei)
%

if ~exist('bins1')
 bins1 = 32;
end

if ~exist('bins2')
 bins2 = 32;
end

count =length(data1(:));

if count ~=length(data2(:))
 error('The input datasets should be of the same length.')
end

% January 29, 2003 (lzollei)
[h,centers,nbins] = histmulti5([data1(:) data2(:)],[bins1,bins2]);
p = h/count;
pdf = p;

% to get rid of the 0-count bins
p(find(p==0))= 0.000001; p = p(:);

je = - sum(p .* log2(p));
