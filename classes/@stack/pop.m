% POP    Pop element off top of stack. Return both stack and element.
%
%		function [s, e] = pop(s)
%
function [s, e] = pop(s)
        if (s.top == 0), error('Cannot pop() empty stack'), end
        e = s.data{s.top};
        s.top = s.top - 1;
