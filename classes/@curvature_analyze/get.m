function val = get(C, astr_propName)
%
% NAME
%
%  function val = get(C, str_propName)
%
% ARGUMENTS
% INPUT
%	C		class		basac_process class
%	astr_propName	string		internal field to access
%
% OPTIONAL
%
% DESCRIPTION
%
%	'get' accesses the internals of the class and returns to caller.
%
% NOTE:
%


switch astr_propName
    % Core class internal data
    case 'mstack_proc'
	val	= c.mstack_proc;

    case 'aparcDir'
        val     = sprintf('%s/%s/%s',                           ...
                            C.mstr_subjectsDir,                 ...
                            C.mstr_analysisDir,                 ...
                            C.ms_annotation.mstr_annotFile);

    otherwise
        error([' "', astr_propName, '" is not valid.'])
end