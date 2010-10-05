function [aM_GWSA, aM_GESA, aM_WMV, aM_GMV, aM_GI, aM_WF] = 	...
			brain_data(varargin)
%
% NAME
%
%  function [aM_GWSA, aM_GESA, aM_WMV, aM_GMV, aM_GI, aM_WF] = 	...
%  			brain_data(<a_summaryCol>)
%
% ARGUMENTS 
%    input
%
%    optional
%	a_summaryCol		int		column index to display in 
%						summary data
%    output
%	aM_GWSA			matrix		Gray white surface area
%	aM_GESA			matrix		Gray exterior surface area
%	aM_WMV			matrix		White matter volume
%	aM_GMV			matrix		Gray matter volume
%	aM_GI			matrix		Gyrification index
%	aM_WF			matrix		White folding
%
% DESCRIPTION
%
%	'brain_data' simply reads a series of log files and returns them
%	as MatLAB matrices. It also determines some derived data.
%
% PRECONDITIONS
%
%	o the gray/white file volumes were created by 'mri_volprocess'.
%	o the files are ordered in increasing age.
%
% POSTCONDITIONS
%
%	o surface areas, volumes, and some calculations are returned
%	o total volume is returned in (ml), i.e. original volume data
%	  is divided by 1000.
%	o surface area is returned in (10^3 mm^2), i.e. original surface
%	  area data divided by 1000.
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

s		= 3;
if length(varargin)
    s		= varargin{1};
end

M_GWSA		= load('grayWhiteSurfaceArea.txt');
M_GESA		= load('grayCSFSurfaceArea.txt');
M_WMV		= load('whiteVolumes.txt');
M_GMV		= load('grayVolumes.txt');

aM_GWSA		= M_GWSA(:, 2:5) ./1000;
aM_GESA		= M_GESA(:, 2:5) ./1000;
aM_WMV		= M_WMV(:, 2:5) ./1000;
aM_GMV		= M_GMV(:, 2:5) ./1000;

aM_GI		= aM_GWSA ./ aM_GESA;
M_WMV23		= aM_WMV .^ (2/3);
aM_WF		= aM_GWSA ./ M_WMV23;

fprintf(1, 'Gray-white total surface area:\n');
disp(aM_GWSA(:,3));
fprintf(1, 'Gray-CSF total surface area:\n');
disp(aM_GESA(:,3));
fprintf(1, 'Gray total volume:\n');
disp(aM_GMV(:,3));
fprintf(1, 'White total volume:\n');
disp(aM_WMV(:,3));
fprintf(1, 'GI:\n');
disp(aM_GI(:,3));
fprintf(1, 'WF:\n');
disp(aM_WF(:,3));


end