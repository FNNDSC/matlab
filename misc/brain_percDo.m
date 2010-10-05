function [aM_total, aM_grayPerc, aM_whitePerc] = 	...
			brain_percDo(astr_grayVol, astr_whiteVol)
%
% NAME
%
%  	function [aM_total, aM_grayPerc, aM_whitePerc] = 	...
%  				brain_percDo(astr_grayVol, astr_whiteVol)
%
% ARGUMENTS 
%    input
%	astr_grayVol		string		gray matter volume filename
%	astr_whiteVol		string		white matter volume filename
%
%    optional
%
%    output
%	aM_total		matrix		total volume 
%	aM_grayPerc		matrix		percentage gray matter
%	aM_whitePerc		matrix		percentage white matter
%
% DESCRIPTION
%
%	'brain_percDo' simply reads the brain matter volumes in the 
%	passed filenames and calculates the total volume, and relative
%	gray/white percentages.
%
% PRECONDITIONS
%
%	o the gray/white file volumes were created by 'mri_volprocess'.
%
% POSTCONDITIONS
%
%	o total and percentage data is returned in matrix form.
%	o total volume is returned in (ml), i.e. original volume data
%	  is divided by 1000.
%
% SEE ALSO
%
% HISTORY
% 13 October 2006
% o Initial design and coding.
%
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

	function [Z] = F(K1, K2)
	    singularity	= find(K2 == 0);
	    if length(singularity)
		fprintf(1, '\n\tSingularity points: %d\t\t', singularity);
		error_exit(	'determining ratio', 		...
				'singularity points found', 	...
				'1')
	    end
	    K2 = K2 .^ (2/3);
	    Z = K1 ./ (K2);
	end


%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 


M_grayVolA	= load(astr_grayVol);
[rows cols]	= size(M_grayVolA);

M_grayVol	= M_grayVolA(:,2:cols) ./ 1000;
M_whiteVolA	= load(astr_whiteVol);
M_whiteVol	= M_whiteVolA(:,2:cols) ./ 1000;

v_subjects	= M_grayVolA(:,1);

aM_total	= zeros(rows, cols);
aM_grayPerc	= zeros(rows, cols);
aM_whitePerc	= zeros(rows, cols);

aM_total(:,1)		= v_subjects;
aM_grayPerc(:,1)	= v_subjects;
aM_whitePerc(:,1)	= v_subjects;

aM_total(:,2:cols)	= M_grayVol + M_whiteVol;
aM_grayPerc(:,2:cols)	= M_grayVol ./ aM_total(:,2:cols) .* 100;
aM_whitePerc(:,2:cols)	= M_whiteVol ./ aM_total(:,2:cols) .* 100;


end