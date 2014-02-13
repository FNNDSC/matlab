function [aM, aM_inv] = invTest(aMatrixSize, aNumberOfLoops, varargin)
%
% NAME
%
%       function [aM_inv] = invTest(aMatrixSize, aNumberOfLoops)
%
%
% ARGUMENTS
%
%       INPUT
%       aMatrixSize     int                     size of matrix
%       aNumberOfLoops  into                    number of inversions to
%                                               loop
%
%       OPTIONAL
%
%       OUTPUT
%       aM_inv          matrix                  the random matrix
%       aM_inv          matrix                  the result after 
%                                               <aNumberOfLoops> inversions.
%
% DESCRIPTION
%
%       'invTest' is a simple script that creates a matrix of size
%       <aMatrixSize> x <aMatrixSize> and then inverts this matrix
%       repeatedly <aNumberOfLoops> times.
%
%       This script is used as a dummy test case demonstrating how to
%       run a MatLAB script on the cluster.
%
% PRECONDITIONS
%
%       o None
%
% POSTCONDITIONS
%
%       o The final inversion is returned.
% 
% SEE ALSO
%
% HISTORY
% 13 February 2014
% o Initial design and coding.
% 
%


tic;
aM      = rand(aMatrixSize, aMatrixSize);
aM_inv  = aM;
for i=1:aNumberOfLoops
        aM_inv = inv(aM_inv);
end
toc;


