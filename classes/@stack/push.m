% PUSH    Add an element to top of stack. Return new stack.
%
%		function s = push(s, x)
%
function s = push(s,x)
    s.top = s.top + 1;      % Increment the top index
    s.data{s.top} = x;      % Add the element to the stack
