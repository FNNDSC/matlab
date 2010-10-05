function [Vo] = vol_reorganise2(Vi)
%
% SYNPOSIS
%	
%	function [Vo] = vol_reorganise2(Vi)
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
%		[k, i, j]	= size(Vi)
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

Vt			= shiftdim(Vi, 1);
Vo 			= Vt;
[rows, cols, slices]	= size(Vt);
for slice = 1:slices,
	Vo(:,:,slice)	= Vt(:,:,slices-slice+1);
end
