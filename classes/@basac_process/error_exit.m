function err = error_exit(c, astr_id, astr_message, varargin)
%
% NAME
%
%  function str_code = error_exit(c, astr_code, astr_message, <ab_exit>)
%
% ARGUMENTS
% INPUT
%	c		class		cortical parellation class
%	astr_id		string		errorID
%	astr_message	string		Error message text.
%
% OPTIONAL
%
% DESCRIPTION
%
%	Allows for graceful exits/warnings from internal errors.
%
% NOTE:
%
% HISTORY
% 19 June 2007
% o Initial design and coding.
%

b_canExit	= 1;
if(length(varargin))
    b_canExit	= varargin{1};
end

[stack, str_proc] = pop(c.mstack_proc);

if(b_canExit)
    fprintf(1, '\nFATAL ERROR -- (%s) %s::%s\n', c.mstr_class, c.mstr_obj, str_proc);
    error(astr_id, astr_message);
else
    fprintf(1, '\nWARNING -- (%s) %s::%s\n', c.mstr_class, c.mstr_obj, str_proc);
    warning(astr_id, astr_message);
end
