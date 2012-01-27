function [d, v_p, s_stats, M_T] = manova_calc(  astr_curvFile, varargin)
%
% NAME
%	function [] = manova_calc(  astr_curvFile, varargin)
%
%
% ARGUMENTS
%       
%       INPUT
%       astr_mris       string          filename of surface file to load
%
%       OPTIONAL
%       astr_title      string          title of plot. If empty string,
%                                       title will be constructed from
%                                       surface and curvature file names.
%                                       If title string starts with "save:"
%                                       then the graph is also saved to
%                                       filesystem using the title string
%                                       as a filestem.
%
%       OUTPUT
%
% DESCRIPTION
%
%       'mris_display' reads a FreeSurfer surface structure and
%       displays it as seen from an optional <a_az, a_el>.
%
%       The <av_curv> can be further band pass filtered by passing
%	an <af_bandFilter> parameter, in which case the curvature
%	vector is hardlimited to [-<af_bandFilter>, ... <af_bandFilter>].
%
% PRECONDITIONS
%       o <astr_mris> and <astr_curv> should be valid filenamesi.
%       o FreeSurfer environment.
%
% POSTCONDITIONS
%       o Figure is generated.
%       o handle to figure is returned.
%
% HISTORY
% 26 August 2009
% o Initial design and coding.
% 
% 02 June 2011
% o Fixed colormap handling for cases where mapping toolbox is not
%   available.
%

% ---------------------------------------------------------

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

	function [avc_groupClassID] = classGroup(avc_origClassID)
	    %
	    % INPUT
	    % 	avc_origClassID		col vector of original classes
	    % 	
	    % OUTPUT
	    % 	avc_groupClassID	col vector of core classes
	    % 	
	    % DESCRIPTION
	    % 	Converts a vector of original class membership/names, e.g.
	    % 	
	    % 		[101 102 103 201 202 301 302 303]' to
	    % 	
	    % 	to
	    % 	
	    % 		[1 1 1 2 2 3 3 3]'
	    % 		

	    % Left justify string representation of orig class ID
	    str_origClassID	= num2str(avc_origClassID, '%-d');
	    str_groupClassID	= str_origClassID(:,1);
	    avc_groupClassID	= str2num(str_groupClassID);
	end

%%%%%%%%%%%%%% 
%%% Nested functions :END
%%%%%%%%%%%%%% 


sys_print('manova_calc: START\n');
 
str_sign	= 'pos';
% Parse optional arguments
if length(varargin) >= 1, str_sign = varargin{1};	end

% Read curvature file
colprintf('40;40', 'Reading curvature file', '[ %s ]\n', astr_curvFile);
[str_h, M_T] = hdrload(astr_curvFile);

switch strcmp(str_sign, 'pos')
    case 1
	M_c	= M_T(:, [4 5]);
    case 0
	M_c	= M_T(:, [2 3]);
    otherwise
	M_c	= M_T(:, [4 5]);
end

vc_groupID	= classGroup(M_T(:, 1));

M_T             = [vc_groupID M_T];

M_p		= [M_c vc_groupID];
[d, v_p, s_stats] 	= manova1( M_c, vc_groupID);

c1      = s_stats.canon(:, 1);
c2      = s_stats.canon(:, 2);
gscatter(c2, c1, vc_groupID, [], 'oxs');
%gname
grid

sys_print('manova_calc: END\n');

end
% ---------------------------------------------------------


