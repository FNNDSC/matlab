function [ret cstr_output] = c_shell(astr_shellArgs, varargin)
%
% NAME
%
%	function [ret cstr_output] = c_shell(astr_shellArgs, varargin)
%
% ARGUMENTS
%
%	INPUT
%	astr_shellArgs	        string	        the shell string to execute
%       
%       OPTIONAL
%       str_delimiter           string          delimiter used to split console
%                                               string results into cell array
%                                               components
%
% DESCRIPTION
%
%       Execute a string in the underlying shell, and return the output 
%       return code, as well as line-delimited output as a cell string.
%
% PRECONDITIONS
%
%	o UNIX runtime
% 
% SEE ALSO
%
% HISTORY
% 14 June 2011
% o Initial design and coding.
%

str_delimiter           = '\n';
if length(varargin)
    str_delimiter       = varargin{1};
end

[ret str_console]       = unix(astr_shellArgs);

if ret ~= 0
    error_exit(['executing command: "' astr_shellArgs '"'],               ...
                sprintf('the system returned an error: (%d) %s', ret, str_console), ...
                '1');
end

str_console     = strtrim(str_console);
str_split       = regexp(str_console, str_delimiter, 'split');
cstr_output     = cellstr(str_split);
