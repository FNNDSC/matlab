function [astr_ret astr_console] = dsh_exec(C, astr_execCmd)
%
% NAME
%
%  function [astr_ret astr_console] = dsh_exec(C, astr_execCmd)
%
% ARGUMENTS
% INPUT
%	C		class		autodijk class
%       astr_execCmd    string          command string to execute using 'dsh'
%
% OPTIONAL
%
% OUTPUT
%       astr_ret        string          dsh console return code
%       astr_console    string          dsh console stdout string
%	
%
% DESCRIPTION
%
%	This method is the main entry point that interacts with the spawned
%       'dsh' process. It is passed a semi-colon delimited list of commands
%       that are simply passed one after the other to the backend engine.
%
% PRECONDITIONS
%
%	o the autodijk class instance must be fully instantiated.
%
% POSTCONDITIONS
%
%
% NOTE:
%
% HISTORY
% 02 November 2009
% o Initial design and coding.
%

C.mstack_proc 	        = push(C.mstack_proc, 'dsh_exec');
verbosityLevel          = C.m_verbosityLevel;
C.m_verbosityLevel      = 3;

str_dshCmd              = sprintf('%s -c \"%s\"', C.mscript_dsh, astr_execCmd);
%  lprintf(C, 'Executing commands via dsh')
[astr_ret astr_console]   = unix(str_dshCmd);
%  colprintf(C, '', '[ ok ]\n');

C.m_verbosityLevel      = verbosityLevel;
[C.mstack_proc, element] = pop(C.mstack_proc);

