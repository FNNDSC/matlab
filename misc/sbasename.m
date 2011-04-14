function [str_basename] = basename(str_pathSpec)
%
% NAME
%	basename
%
% SYNPOSIS
%	basename <pathSpec>
%
% DESCRIPTION
%	This function is a simple implementation of the POSIX 'basename'
%       command
%
%

[upperPath, deepestFolder, ~] = fileparts(str_pathSpec);

str_basename = deepestFolder;

