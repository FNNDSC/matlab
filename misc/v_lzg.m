function [av_l, av_z, av_g] = v_lzg(av_in, varargin)
%
% NAME
%
%	function [av_l, av_z, av_g] = v_lzg(av_in)
%
% ARGUMENTS
% INPUT
%	av_in           vector          input vector
%       
% OUTPUTS
%	av_l		vector          vector of av_in elements less than 0
%	av_z		vector          vector of av_in elements equal to 0
%	av_g		vector          vector of av_in elements greater than 0
%
% DESCRIPTION
%
%	'v_lzg' simply accepts an input vector and returns three compressed vectors
%       containing elements less than, equal to, and greater than zero.
%
% PRECONDITIONS
%
% 	o av_in must be a vector.
%       
% POSTCONDITIONS
%       
%       o av_l, av_z, av_g are returned.
%
% HISTORY
% 15 October 2009
% o Initial design and coding.
%

if ~is_vect(av_in)
    error_exit( 'checking input argument',      ...
                '<av_in> must be a vector',     ...
                '1');
end


av_l = compress(av_in, 0, 'lt');
av_z = compress(av_in, 0, 'eq');
av_g = compress(av_in, 0, 'gt');

