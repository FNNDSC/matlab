function val = get(c, astr_propName)
%
% NAME
%
%  function val = get(c, astr_propName)
%
% ARGUMENTS
% INPUT
%	c		class		basac_process class
%	astr_propName	string		internal field to access
%
% OPTIONAL
%
% DESCRIPTION
%
%	'get' accesses the internals of the class to stdout.
%
% NOTE:
%
% HISTORY
% 16 December 2008
% o Initial design and coding.
%

switch astr_propName
    % Core class internal data
    case 'mstack_proc'
	val	= c.mstack_proc;

    % Data internal source
    case 'Dim'
	val	= c.mv_dims;
    case 'Rows'
        val	= rows;
    case 'Cols'
        val 	= cols;
    case 'Slices'
        val 	= slices;
    case 'Data'
	val	= c.mV_data;

    % Metadata
    case 'PID'
        val 	= c.mstr_PID;
    case 'Scan'
        val 	= c.mstr_scan;
    case 'FSBaseDir'
        val 	= c.mstr_FSBaseDir;
    case 'verbosity'
	val	= c.m_verbosity;
    otherwise
        error([' "', astr_propName, '" is not valid.'])
end