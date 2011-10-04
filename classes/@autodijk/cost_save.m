function C = cost_save(C, varargin)
%
% NAME
%
%  function C = cost_save(C)
%
% ARGUMENTS
% INPUT
%	C		class		autodijk class
%
% OPTIONAL
%
% OUTPUT
%	C		class		autodijk class
%	
%
% DESCRIPTION
%
%	This method simply saves the cost overlay to the filesystem.
%
% PRECONDITIONS
%
%	o the autodijk class instance must be fully instantiated.
%       o the backend search engine is shutdown.
%
% POSTCONDITIONS
%
%
% NOTE:
%
% HISTORY
% 03 November 2009
% o Initial design and coding.
%

C.mstack_proc 	= push(C.mstack_proc, 'cost_save');
verbosityLevel          = C.m_verbosityLevel;
C.m_verbosityLevel      = 2;

lprintf(C, 'Saving output to %s', C.mstr_outputFileName);

str_saveFile    = sprintf('%s/%s',      ...
        C.mstr_outputDir, C.mstr_outputFileName);

write_curv(str_saveFile, C.mv_output, C.mfnum);
rprintf(C, '[ ok ]\n');

lprintf(C, 'Closing text output file %s...', C.mstr_outputTxtFile);
fclose(C.mfid_outputTxtFile);
rprintf(C, '[ ok ]\n')


lprintf(C, 'Shutting down backend infrastructure');
str_dsh         = 'TERM';
dsh_exec(C, str_dsh);
rprintf(C, '[ ok ]\n');

f_mean          = mean(C.mv_output);
f_std           = std(C.mv_output);
colprintf(C, 'mean cost', '[ %f ]\n', f_mean);
colprintf(C, 'std  cost', '[ %f ]\n', f_std);
colprintf(C, 'mean non-zero cost', '[ %f ]\n', mean(C.mv_output(find(C.mv_output>0))));
colprintf(C, 'std  non-zero cost', '[ %f ]\n', std(C.mv_output(find(C.mv_output>0))));

C.m_verbosityLevel      = verbosityLevel;
[C.mstack_proc, element] = pop(C.mstack_proc);

