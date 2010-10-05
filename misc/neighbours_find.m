function [I, D] = neighbours_find(n, d)
%//
%// ARGS
%//   I         out         a cell array containing "indirect"
%//                             neighbour information. Each index
%//                             of the cell array is a row-order
%//                             matrix of "index" distant
%//                             indirect neighbours
%//   D         out         a cell array containing "direct"
%//                             neighbour information. Each index
%//                             of the cell array is a row-order
%//                             matrix of "index" distant
%//                             direct neighbours
%//   n         in          number of dimensions
%//   d         in          depth of neighbours to find
%//
%// DESC
%//   This method determines the neighbours of a point in an 
%//   n-dimensional discrete space. The "depth" (or ply) to
%//   calculate is `d'.
%//
%//   Indirect neighbours are non-orthogonormal.
%//   Direct neighbours are orthonormal.
%//
%// PRECONDITIONS
%// o The underlying problem is discrete.
%//
%// POSTCONDITIONS
%// o I cell array contains the Indirect neighbours
%// o D cell array contains the Direct neighbours
%// o size{I} = size{D}
%// o size{I} = d
%//
%// BUGS
%// o For multidimensional spaces and deep ply depth, this
%//   method is almost prohibitively slow (20010927)
%//
%// HISTORY
%// 21 September 2001
%// o Intial design and coding.
%//
%// 26 September 2001
%// o Expansion to `d' depth neighbours
%//

bD_offset   = ones(1, n) * -d;

ii  = ones(1, d);        % index counter in indirect matrix
dd  = ones(1, d);        % index counter in direct matrix

loop = (2*d+1)^n

for i=0:loop-1
    str_progress = sprintf('iteration: %d (of %d) %f\n', i, loop-1, i/(loop-1))
    bD          = b10_convertFrom(i, (2*d+1), n);
    bD          = bD + bD_offset;
    neighbour   = max(abs(bD));
    if(sum(abs(bD))>neighbour)
        I{neighbour}(ii(neighbour), :)      = bD;
        ii(neighbour)=ii(neighbour)+1;
    else 
        if(sum(abs(bD))==neighbour & neighbour)
            D{neighbour}(dd(neighbour), :)  = bD;
            dd(neighbour)=dd(neighbour)+1;
        end
    end
end
