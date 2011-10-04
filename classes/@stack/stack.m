% STACK    Create an empty stack object
%    Constructor for a simple stack class using a cell-array.
%
%		function s = stack()
%
%    Peter Webb and Gregory V. Wilson, Matlab as a Scripting Language,
%  	Dr Dobbs Journal, January, 1999.
%
function s = stack()
   s.data = {};            % Make an empty cell-array
   s.top = 0;              % Nothing in the stack yet
   s = class(s, 'stack');  % Turn the structure into a class object
