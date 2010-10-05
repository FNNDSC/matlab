function [I, D] = neighbours_findFast(a_dimension, a_depth)
%//
%// SYNOPSIS
%//      [I, D] = neighbours_findFast(a_dimension, a_depth)
%//
%// ARGS
%//   I             out         a cell array containing "indirect"
%//                                 neighbour information. Each index
%//                                 of the cell array is a row-order
%//                                 matrix of "index" distant
%//                                 indirect neighbours
%//   D             out         a cell array containing "direct"
%//                                 neighbour information. Each index
%//                                 of the cell array is a row-order
%//                                 matrix of "index" distant
%//                                 direct neighbours
%//   a_dimension   in          number of dimensions
%//   a_depth       in          depth of neighbours to find
%//
%// DESC
%//   This method determines the neighbours of a point in an 
%//   n-dimensional discrete space. The "depth" (or ply) to
%//   calculate is `a_depth'.
%//
%//   Indirect neighbours are non-orthogonormal.
%//   Direct neighbours are orthonormal.
%//
%//   This is the same method, conceptually, as neighbours_find,
%//   but enhanced for speed.
%//
%// PRECONDITIONS
%// o The underlying problem is discrete.
%//
%// POSTCONDITIONS
%// o I cell array contains the Indirect neighbours
%// o D cell array contains the Direct neighbours
%// o size{I} = size{D}
%// o size{I} = a_depth
%//
%// HISTORY
%// 21 September 2001
%// o Intial design and coding.
%//
%// 26 September 2001
%// o Expansion to `d' depth neighbours
%//
%// 27 September 2001
%// o Speed enhancements - basically retranslated the C++
%//   implementation of the original back into MATLab - 
%//   explicitly allocating structures, etc.
%//

%// Allocate space for neighbours structure
D = cell(1, a_depth);
I = cell(1, a_depth);

%// Create data structures
d               = 1;
hypercube       = (2*d+1)^a_dimension;
hypercubeInner  = 1;
orthogonals     = 2*a_dimension;
D{1}            = zeros(orthogonals,                a_dimension);
I{1}            = zeros(hypercube - orthogonals -1, a_dimension);
for d=2:a_depth
    hypercubeInner  = hypercube;
    hypercube       = (2*d+1)^a_dimension;
    D{d}            = zeros(orthogonals,            a_dimension);
    I{d}            = zeros(hypercube - orthogonals - hypercubeInner, a_dimension);
end

%// Offset and "current" vector
M_bDoffset      = ones(1, a_dimension) * -a_depth;
M_current       = ones(1, a_dimension);
M_currentAbs    = ones(1, a_dimension);

%// Index counters
M_ii            = ones(1, a_depth);
M_dd            = ones(1, a_depth);

%// Now we loop through *each* element of the last hypercube
%// and assign it to the appropriate matrix in the I,D structures
for i=0:hypercube-1
    str_progress = sprintf('iteration: %d (of %d) %f\n', i, hypercube-1, i/(hypercube-1))
    M_current       = b10_convertFrom(i, (2*a_depth+1), a_dimension);
    M_current       = M_current + M_bDoffset;
    M_currentAbs    = abs(M_current);
    neighbour   = max(M_currentAbs);
    if(sum(M_currentAbs) > neighbour)
        I{neighbour}(M_ii(neighbour), :)        = M_current;
        M_ii(neighbour) = M_ii(neighbour)+1;
    else 
        if(sum(M_currentAbs) == neighbour & neighbour)
            D{neighbour}(M_dd(neighbour), :)    = M_current;
            M_dd(neighbour) = M_dd(neighbour)+1;
        end
    end
end
