function [av_c] = centroidPC_find(aM_x, varargin)
%
% NAME
%
%       function [av_c] = centroid_points(aM_x, varargin)
%
%
% ARGUMENTS
%
%       INPUT
%       aM_x            matrix                  a column dominant matrix of 
%                                               size MxN. The first (N-1)
%                                               columns define the points in
%                                               the space, and the final column
%                                               defines the mass located at
%                                               the point.
%
%       OPTIONAL
%       ab_Xcentroids   bool                    specifies if the "X" vector
%                                               field denotes the position of
%                                               centroids. If false, then
%                                               X field centroids are placed
%                                               equadistant between X 
%                                               successive coords.
%
%
%       OUTPUT
%       av_c            vector                  The centroid of the aM_x cloud.
%
% DESCRIPTION
%
%       'centroidPC_find' returns the centroid of the point cloud defined in an
%       arbitrary space where the first N-1 colums define the dimensionality 
%       of the space, and the final column N denotes the mass located at a given
%       point.
%
% PRECONDITIONS
%
%
% POSTCONDITIONS
%
%       o The centroid of the point cloud space described by aM_x is returned.
% 
% SEE ALSO
%
% HISTORY
% 04 February 2014
% o Initial design and coding.
% 
%

[rows cols]     = size(aM_x);

v_mass          = aM_x(:,cols);
M_mass          = repmat(v_mass, 1, cols-1);
M_points        = aM_x(:,[1:cols-1]);

av_c            = 1/sum(v_mass) * sum(M_points .* M_mass);

