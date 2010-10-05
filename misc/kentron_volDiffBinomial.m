function [] = kentron_volDiffBinomial(ai, varargin)
% NAME
%
%  function [] = kentron_volDiffBinomial(ai
%  				[ 	a_slabDir=<direction>,
%					a_inPlaneDir=<direction>])
%
%
% ARGUMENTS
% inputs
%	ai			int		population size
%
% optional
%	a_slabDir		int		plane direction to analyze:
%						1 - row
%						2 - col
%						3 - slice
%	a_inPlaneDir		int		in-plane direction to analyze:
%						1 - rowDir (i.e. across rows
%							or "up/down")
%						2 - colDir (i.e. across cols
%							or "left/right")
%
% outputs
%
% DESCRIPTION
%
%	'kentron_volDiffBinomial' runs a 'kentron_volDiff' in a
%	binomial expansion manner. The <ai> "normal" DTI volumes
%	are diffed in all possible combinations.
%
% PRECONDITIONS
%
%	o Input volumes are MGH format.
%
% POSTCONDITIONS
%
%	o Volume analysis is presented in both a returned volume and a 3D mesh.
%
% SEE ALSO
%
%	o binomial.m
%	o binomialInd_2find.m
%
% HISTORY
%
% 21 September 2006
% o Initial design and coding.
%

%%%%%%%%%%%%%% 
%%% Nested functions
%%%%%%%%%%%%%% 
	function error_exit(	str_action, str_msg, str_ret)
		fprintf(1, '\tFATAL:\n');
		fprintf(1, '\tSorry, some error has occurred.\n');
		fprintf(1, '\tWhile %s,\n', str_action);
		fprintf(1, '\t%s\n', str_msg);
		error(str_ret);
	end

	function vprintf(level, str_msg)
	    if verbosity >= level
		fprintf(1, str_msg);
	    end
	end

%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 

c		= binomial(ai, 2);
M_ind		= binomialInd_2find(ai);

for i = 1:c
    str_i	= sprintf('f_ave.%d.mgh', M_ind(i, 1));
    str_j	= sprintf('f_ave.%d.mgh', M_ind(i, 2));
    kentron_volDiff(str_i, str_j)
end


end