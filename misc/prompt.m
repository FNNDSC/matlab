function prompt(varargin)

%  NAME
%  	prompt
%  
%  SYNOPSIS
%  
%  	prompt(varargin)
%
%  ARGS
%  INPUTS
%	varargin		in		if any variable is passed,
%						the 'prompt' will pause
%						before evaluating the 
%						input() function call. This
%						helps to prevent MatLAB 
%                                               from hogging the processor.
%
%  
%  DESCRIPTION
%  
%  	'prompt' simulates a MatLAB command line prompt replacement,
%  	changing the default '>>' to be more similar to a bash-shell
%  	type prompt wherein the last two directory nodes of the 
%  	current path are shown, or, if the entire path is less than
%  	20 characters, the whole path is shown.
%  

function prompt_wait_for_input(astr_prompt)
    str_userInput = input(astr_prompt, 's');
    try
        eval(str_userInput);
    catch ME
        fprintf('An error occured in your expression:');
        ME
    end
end

[str_ret, str_machine]  = system('uname -m');
[str_ret, str_OS]       = system('uname -o');
if str_ret 
    [str_ret, str_OS]   = system('uname -s');
end
[str_ret, str_host]     = system('hostname');
str_machine             = strtok(str_machine);
str_OS                  = strtrim(str_OS);
str_host		= strtok(strtrim(str_host), '.');
b_pause                 = 0;

if length(varargin), b_pause 	= 1;, end

while 1
	str_endNode	= basename(pwd);
	str_prevNode	= basename(fileparts(pwd));
	if length(pwd) < 20 
		str_prompt	= sprintf('[%s:%s-%s]%s>> ',            ...
                                        str_host, str_machine, str_OS,  ...
                                        pwd);
	else
		str_prompt	= sprintf('[%s:%s-%s].../%s/%s>> ',     ...
                                  str_host, str_machine, str_OS,        ...
                                  str_prevNode, str_endNode);
	end
	if b_pause 
		pause 
	end
%	PromptCommand	= input(str_prompt, 's');
%	eval(PromptCommand);
        prompt_wait_for_input(str_prompt);
        c = onCleanup(@()prompt_wait_for_input(str_prompt));
end

end
