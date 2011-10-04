% DISPLAY   Print contents of a stack object.
% Called automatically to print object when necessary
function display(s)
    fprintf('\n');
    if s.top == 1
	str_elements = 'element';
    else
	str_elements = 'elements';
    end
    fprintf('Stack object: contains %d %s\n', s.top, str_elements);
    fprintf('\n');
    for i=1:s.top
	fprintf('%20d: ', i);
	disp(s.data{i});
    end
    fprintf('\n');
