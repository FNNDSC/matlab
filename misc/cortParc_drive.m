function [c] =	cortParc_drive(varargin)
%
% NAME
%
%  function [] =	cortParc_drive()
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%
% OUTPUTS
%					connect the points of the polygon
%
% DESCRIPTION
%
%	'cortParc_drive' "drives" a cortical parcellation process. It provides
%	a convenient entry point to starting and initializing a cortical
%	parcellation process.
%
% PRECONDITIONS
%
%	o None
%
% POSTCONDITIONS
%
%	o A debugging run through the cortParc class is performed.
%
% NOTE:
%
% HISTORY
% 27 June 2007
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

%%%%%%%%%%%%%% 
%%% Nested functions :END
%%%%%%%%%%%%%% 

c	= cortParc();
%  c	= set(c, 'flags', 1);
c	= set(c, 'flags', 		4);
c	= set(c, 'sulcusTable', 	'4200_dlbss5.sulci');
%  c	= set(c, 'sulcusTable', 	'rosePhantom_table.txt');
c	= set(c, 'PID', 		'4200');
c	= set(c, 'Scan', 		'5');
c	= set(c, 'visuals', 		0);
c	= set(c, 'imagesSave',		1);
c	= set(c, 'verbosity',		1);
c	= set(c, 'intersectsInCortex',	1);
c	= set(c, 'meanInCortex',	1);
c	= set(c, 'cleanSlicesSave',	1);
c	= run(c);

end
