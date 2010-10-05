function [] = error_exit(str_action, str_message, str_ret, varargin)
%
% NAME
%
%	function [] = error_exit(str_action, str_message, str_ret [, colWidth])
%
%
% ARGUMENTS
% input
%	str_action		string		the event/action during which
%						an error condition occurred
%	str_message		string		corrective/decriptive message
%	str_ret			string		error return string
%
%	colWidth		int (opt)	an optional column width
%						specifier.
%
% global depends
%	str_name		string		a global string defining the
%						current function being executed
% output
%	[]
%
% DESCRIPTION
%	
%	'error_exit' is a simple error message reporting function that
%	prints some information to stdout and then exits the running
%	process thread.
%
% HISTORY
% 23 January 2006
% o Initial design and coding.
%

colWidth	= 0;

if length(varargin)
	colWidth	= varargin{1};
	if ~isnumeric(colWidth)
		colWidth	= 0;
	end
end

fmt	= sprintf('\t%%-%ds', colWidth);

global	str_functionName;

if length(str_functionName)
	fprintf('%s.m:\n', str_functionName)
end
fprintf([ fmt '\n'], 'FATAL ERROR:');

fprintf([ fmt '\n'], sprintf('Sorry, some error has occurred.'));
fprintf([ fmt '\n'], sprintf('While %s,', str_action));
fprintf([ fmt '\n'], sprintf('%s', str_message));
fprintf([ fmt '\n'], sprintf('\n\nError code: %s', str_ret));
error(str_ret);

