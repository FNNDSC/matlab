function [V] = vol_imadjust(a_V)
%
% [V] = vol_imadjust(a_V)
%
% ARGS
% INPUT
% a_V			vol                     volume data to imadjust
% 
% DESC
% Run each slice in a_V through 'imadjust'.
%
% HISTORY
% 04 December 2008
% o Initial design and coding.
%

V       = a_V;
sz      = size(V);

for slice   = 1:sz(3)
    V(:,:,slice)    = imadjust(a_V(:,:,slice));
end
