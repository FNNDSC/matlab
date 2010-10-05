function [l, z, g] = lzg(av_in, varargin)
%
% NAME
%
%	function [l, z, g] = lzg(av_in [, ab_percent])
%
% ARGUMENTS
% INPUT
%	av_in           vector          input vector
%       
% OPTIONAL      
%	ab_percent      bool		if specified, return l, z, g as
%				        percentages of original array
%				        length.
%
% OUTPUTS
%	l		int/float	count/perc of elements less than zero
%	z		int/float	count/perc of elements equal to zero
%	g		int/float	count of elemente greater than zero
%
% DESCRIPTION
%
%	'lzg' simply accepts an array and returns the number of
%	elements that are less than zero 'l', zero 'z', and 
%	greater than zero, 'g'.
%
% PRECONDITIONS
%
% 	o av_in must be a vector.
%
% HISTORY
% 09 January 2006
% o Initial design and coding.
%
% 15 October 2009
% o 'Cosmetic' updates.
%

if ~is_vect(av_in)
    error_exit( 'checking input argument',      ...
                '<av_in> must be a vector',     ...
                '1');
end

b_percent = 0;
if length(varargin)
	b_percent = varargin{1};
end

v_l = av_in(av_in <  0);
v_z = av_in(av_in == 0);
v_g = av_in(av_in >  0);

l       = numel(v_l);
z       = numel(v_z);
g       = numel(v_g);

el      = numel(av_in);

if b_percent
	l = l / el;
	z = z / el;
	g = g / el;
end