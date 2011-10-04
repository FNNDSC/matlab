function display(c)
%
% NAME
%
%  function display(c)
%
% ARGUMENTS
% INPUT
%	c		class		cortical parellation class
%
% OPTIONAL
%
% DESCRIPTION
%
%	'display' writes the internals of the class to stdout. It simply
%	converts the class to a struct and displays the struct.
%
% NOTE:
%
% HISTORY
% 12 June 2007
% o Initial design and coding.
%


s	= struct(c);
disp(s)
