function [mi, hAB, hA, hB] = mutual_information(A, B, binsA, binsB, overlap)

%
% Calculates the mutual information between the input
% variables.
%
% Written: April 3, 2002 (lzollei)
% Modified: November 17, 2002 (lzollei)
%

if ~exist('overlap')
     overlap = 0;
end

if overlap == 1
 ind = find(~(isnan(B)));
 B = B(ind);
 A = A(ind);
end

hAB = sh_j_entropy(A,B,binsA,binsB);
%keyboard
hA  = sh_entropy(A,binsA);
hB  = sh_entropy(B,binsB);

mi = hA + hB - hAB;
