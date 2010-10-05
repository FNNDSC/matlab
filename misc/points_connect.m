function [aM] =	points_connect(av_P1, av_P2, a_numConnect)
%
% NAME
%
%  function [av] =	points_connect(av_P1, av_P2, a_numConnect)
%
% ARGUMENTS
% INPUT
%	av_P1		vector		Point 1
%	av_P2		vector		Point 2
%	a_numConnect	int		Number of intermediate points
%					connecting P1 and P2
%
% OPTIONAL
%
% OUTPUTS
%	aM		matrix		table of points that linearly
%					connect P1 and P2
%
% DESCRIPTION
%
%	'points_connect' linearly connects the two input points with
%	<a_numConnect> intermediate points.
%
% PRECONDITIONS
%
%	o av_P1 and av_P2 must be the same size, and must be vectors.
%
% POSTCONDITIONS
%
%	o Matrix (i.e. table) of interconnecting points is returned.
%	o The first and last entries of this interconnection matrix
%	  are the av_P1 and av_P2 points themselves.
%
% SEE ALSO
%
% HISTORY
% 17 May 2007
% o Initial design and coding.
%
%

%%%%%%%%%%%%%% 
%%% Nested functions :START
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
%%% Nested functions :END
%%%%%%%%%%%%%% 

vecSize	= length(av_P1);
if length(av_P1) ~= length(av_P2)
	error_exit(	'checking input parameters',		...
			'<P1> and <P2> are not the same size',	...
			'1');
end

if a_numConnect == -1
    a_numConnect = 0;
end

a_numConnect		= round(a_numConnect);

aM			= zeros(a_numConnect+2, vecSize);
aM(1,:)			= av_P1;
aM(a_numConnect+2,:)	= av_P2;

v_diff			= av_P2 - av_P1;
f_del			= 1/(a_numConnect+1);
if a_numConnect >= 0
    for i=0:a_numConnect+1
        aM(i+1,:)		= av_P1 + i*f_del*v_diff;
    end
end


end