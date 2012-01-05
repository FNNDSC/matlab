function [I, D] = permutations_find(a_dimension, a_depth, varargin)
%
% SYNOPSIS
%      [I, D] = permutations_find(a_dimension, a_depth <,av_origin>)
%
% ARGS
% 
%   INPUT
%   a_dimension         int32           number of dimensions
%   a_depth             int32           depth of neighbours to find
%
%   OPTIONAL
%   av_origin           vector          row vector that defines the
%                                       + origin in the <a_dimension>  
%                                       + space. Neighbours' locations
%                                       + are returned relative to this
%                                       + origin. Default is the zero
%                                       + origin.
%   
%   OUTPUT
%   I                   cell           a cell array containing "indirect"
%                                           neighbour information. Each index
%                                           of the cell array is a row-order
%                                           matrix of "index" distant
%                                           indirect neighbours
%   D                   cell           a cell array containing "direct"
%                                           neighbour information. Each index
%                                           of the cell array is a row-order
%                                           matrix of "index" distant
%                                           direct neighbours
%
% DESC
%       This method determines the neighbours of a point in an
%       n-dimensional discrete space. The "depth" (or ply) to
%       calculate is `a_depth'.
%
%       Indirect neighbours are non-orthogonormal.
%       Direct neighbours are orthonormal.
%       
%       This operation is identical to finding all the permutations
%       of a given set of elements.
%
%
% PRECONDITIONS
%       o The underlying problem is discrete.
%
% POSTCONDITIONS
%       o I cell array contains the Indirect neighbours
%       o D cell array contains the Direct neighbours
%       o size{I} = size{D}
%       o size{I} = a_depth
%
% HISTORY
% 21 September 2001
% o Intial design and coding.
%
% 26 September 2001
% o Expansion to `d' depth neighbours
%
% 27 September 2001
% o Speed enhancements - basically retranslated the C++
%   implementation of the original back into MATLab -
%   explicitly allocating structures, etc.
%
% 06 June 2010
% o Resurrected with av_origin option.
% 

if (a_depth<1)
    D = {};
    I = {};
    return;
end

% Allocate space for neighbours structure
D = cell(1, a_depth);
I = cell(1, a_depth);

% Create data structures
v_origin        = zeros(1, a_dimension);
b_origin        = 0;
if length(varargin)
    av_origin   = varargin{1};
    if isrow(av_origin) && numel(av_origin)==a_dimension
        v_origin        = av_origin;
        b_origin        = 1;
    end
end
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

% Offset and "current" vector
M_bDoffset      = ones(1, a_dimension) * -a_depth;
M_current       = ones(1, a_dimension);
M_currentAbs    = ones(1, a_dimension);

% Index counters
M_ii            = ones(1, a_depth);
M_dd            = ones(1, a_depth);

% Now we loop through *each* element of the last hypercube
% and assign it to the appropriate matrix in the I,D structures
for i=0:hypercube-1
    str_progress    = sprintf('iteration %5d (of %5d) %3.2f',     ...
                                i, hypercube-1, i/(hypercube-1)*100);
    M_current       = b10_convertFrom(i, (2*a_depth+1), a_dimension);
    M_current       = M_current + M_bDoffset;
    M_currentAbs    = abs(M_current);
    neighbour       = max(M_currentAbs);
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

fprintf('\n');

if b_origin
    for layer=1:neighbour
        [rowsI colsI]   = size(I{layer});
        [rowsD colsD]   = size(D{layer});
        M_OI            = repmat(v_origin, rowsI, 1);
        M_OD            = repmat(v_origin, rowsD, 1);
        I{layer}        = I{layer} + M_OI;
        D{layer}        = D{layer} + M_OD;
    end
end
