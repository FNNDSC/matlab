function ret = kentron_artifactClean(	astr_templateName,	...
					astr_targetName,	...
					astr_outputName,	...
					varargin)
% NAME
%
%	function ret = kentron_artifactClean(	astr_templateName,
%						astr_targetName,
%						astr_outputName [,
%						af_k])
%
%
% ARGUMENTS
% inputs
%	astr_templateName	string		name of the "smoothed" template
%						volume file
%	astr_targetName		string		name of the volume to "correct"
%	astr_outputName		string		name of the output volume
%
% optional
%	af_k			float		scale factor		
%
% outputs
%	ret			bool		Boolean: OK or not OK
%
% DESCRIPTION
%
%
% PRECONDITIONS
%
%
% POSTCONDITIONS
%
%
% SEE ALSO
%
%
% HISTORY
%
% 20 July 2006
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

ret		= 0;
f_k		= 0.5;

if length(varargin)
	f_k	= varargin{1};
end

str_msg 		= sprintf('Reading inputs <%s> and <%s>...', ...
					astr_templateName, astr_targetName);
fprintf(1, '%55s', str_msg);
[V_template, Mtmpl_vox2ras, vtmpl_mrParms] 	= load_mgh2(astr_templateName);
[V_target,   Mtarg_vox2ras, vtarg_mrParms] 	= load_mgh2(astr_targetName);
fprintf(1, '%25s\n', '[ ok ]');

str_msg 		= sprintf(	...
			'Finding difference and correcting (k=%f)...', ...
			f_k);
fprintf(1, '%55s', str_msg);
V_output		= V_target;
Vdiff			= V_template - V_target;
V_offset		= f_k .* Vdiff;
V_output		= V_output + V_offset;
fprintf(1, '%25s\n', '[ ok ]');

str_msg 		= sprintf('Saving output volume <%s>...', astr_outputName);
fprintf(1, '%55s', str_msg);
save_mgh(V_output, astr_outputName, Mtarg_vox2ras, vtarg_mrParms);
fprintf(1, '%25s\n', '[ ok ]');

ret		= 1;

end
