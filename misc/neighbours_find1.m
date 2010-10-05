function [I, D] = neighbours_find(n)
%//
%// ARGS
%//   I         out         a matrix containing (in row-order)
%//                             the coordinates of indirect
%//                             neighbours
%//   D         out         a matrix containing (in row-order)
%//                             the coordinates of direct
%//                             neighbours
%//   n         in          size of dimensional space
%//
%// DESC
%//   This method determines the neighbours of a point in an 
%//   n-dimensional discrete space.
%//
%//   Indirect neighbours are non-orthogonormal.
%//   Direct neighbours are orthonormal.
%//
%// PRECONDITIONS
%// o The underlying problem is discrete.
%//
%// POSTCONDITIONS
%// o I contains the Indirect neighbours
%// o D contains the Direct neighbours
%//
%// HISTORY
%// 21 September 2001
%// o Intial design and coding.
%//

b3_offset   = ones(1, n) * -1;

ii  = 1;        % index counter in indirect matrix
dd  = 1;        % index counter in direct matrix
for i=0:3^n-1
    b3          = b10_convertFrom(i, 3, n);
    b3          = b3 + b3_offset;
    if(sum(abs(b3))>1)
        I(ii, :)     = b3;
        ii=ii+1;
    else 
        if(sum(abs(b3))==1)
            D(dd, :)      =b3;
            dd=dd+1;
        end
    end
end
