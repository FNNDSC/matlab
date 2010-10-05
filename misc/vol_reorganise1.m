function [Vo] = vol_reorganise1(Vi)
%
% SYNPOSIS
%	
%	function [Vo] = vol_reorganise1(Vi)
%
% ARGS
%
%	Vi		in		input volume to reorganise
%	Vo		out		output volume
%
% DESC
%
%	This simple function re-organises the indexing of a given
%	3D volume, Vi. Assuming dimensions labelled as:
%
%		[k, j, i]	= size(Vi)
%
%	we create a reorganised structure such that
%
%		[i, j, k]	= size(Vo)
%
%	Such a re-arrangement arises because the C++ based off-line
%	reconstruction software, mdh_process, indexes its image volumes
%	in [i j k] order. Anders' original MatLAB prototypes indexed
%	volumes in [k, j, i] order.
%
%	Scanner dimensions are:
%		i:	linesReadOut
%		j:	linesPhaseEncode
%		k:	partitions (slices)
%
% PRECONDITIONS
% o Make sure that Vi is 3 dimensional!
% 
% HISTORY
% 12 May 2004
% o Initial design and coding.
%

[k,j,i]	= size(Vi);

Vt	= dataSet3D_create(j, k, i);

for slice = 1:i
    Vt(:,:,slice) = Vi(:,:,slice)';
end

Vo	= shiftdim(Vt, 2);
