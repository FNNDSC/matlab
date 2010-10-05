function [ab_ret] = fid_echoesProcess(	astr_echoN,	...
					astr_echoM,	...
					varargin)
%
% NAME
%
%  function [ab_ret ] = fid_echoesProcess(	astr_echoN,	...
%  						astr_echoM[,	...
%  						astr_echoDel,
%						ab_convertToAnalyze])
%
% ARGUMENTS
%	INPUT
%	astr_echoN		string		filename of volume echo N
%	astr_echoM		string		filename of volume echo M
%
%				OPTIONAL
%	astr_echoDel		string		filename stem of del volume
%	ab_convertToAnalyze	boolean		if true, also convert output
%						to Analyze format.
%			
%	OUTPUT
%	ab_ret			boolean		return - 
%						true: no error
%						false: an error occurred
%
% DESCRIPTION
%
%	'fid_echoesProcess' deterimes the difference between
%	echoN and echoM, i.e.:
%
%		echoDel		= echoN - echoM
%
% PRECONDITIONS
%
%	o echoN and echoM are MGH-format volumes
%
% POSTCONDITIONS
%
%	o The difference is saved as an MGH-format volume and also converted
%	  to analyze format.
%
% HISTORY
% 27 June  2006
% o Initial design and coding.
%
% 29 June 2006
% o Also convert to Analyze format.
%

%%%%%%%%%%%%%% 
%%% Nested functions
%%%%%%%%%%%%%% 
	function vprintf(level, str_msg)
	    if verbosity >= level
		fprintf(1, str_msg);
	    end
	end
%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 

%
% Parse inputs
%
str_echoDelStem		= '/tmp/echoDel';
b_convertToAnalyze	= 1;

if length(varargin)
	str_echoDel			= varargin{1};
	if length(varargin) == 2
		b_convertToAnalyze	= varargin{2};
	end
end

[V_echoN, M_vox2ras, M_MRparams]	= load_mgh2(astr_echoN);
[V_echoM, M_vox2ras, M_MRparams]	= load_mgh2(astr_echoM);

try 
	V_echoDel 	= V_echoN - V_echoM;
catch
	error_exit(	'subtracting phase echo volumes', ...
			'an invalid volume was detected.', '1')
end
	
str_echoDelMGH	= sprintf('%s.mgh', str_echoDelStem);
str_echoDelIMG	= sprintf('%s.img', str_echoDelStem);
ret		= save_mgh2(V_echoDel, str_echoDelMGH, M_vox2ras, M_MRparams);

if b_convertToAnalyze
	str_mriConvert		= sprintf('mri_convert %s %s', ...
				str_echoDelMGH, str_echoDelIMG);
	[ret str_console]	= unix(str_mriConvert, '-echo');
	if ret
		error_exit('converting from MGH to IMG format',		...
			   'an error was returned from "mri_convert".',	...
			    '2');
	end
end

end

