function [aM] = grid_make(av)
%
% NAME
%
%  function [aM] = grid_make(av)
%
% ARGUMENTS
% INPUT
%       av              vector                  row vector
%
% OPTIONAL
% 
% OUTPUT
%       aM              matrix                  grid
%
% DESCRIPTION
%
%       'grid_make' converts a vector in to a grid. The grid tries
%       to be square-ish, so perfect fitting is often not possible.
%       
%       The function is used mostly when a group of plots need to
%       'subplotted'.
%       
% PRECONDITIONS
%       
%       o <av> must be a vector
%       
% POSTCONDITIONS
% 
%       o a matrix <aM> representing the closest 'square-ish' grid
%         that incorporates <av> is returned.
%       o if <av> is not a vector, <aM> = []
%
% NOTE:
%
% HISTORY
% 30 September 2009
% o Initial design and coding.
%

if is_vect(av)
    cols        = ceil(sqrt(numel(av)));
    rows        = ceil(numel(av)/cols);
    aM          = zeros(rows, cols);
else
    aM          = [];
end
