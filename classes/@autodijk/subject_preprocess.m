function C = subject_preprocess(C, varargin)
%
% NAME
%
%  function C = subjects_preprocess(C)
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
%       The main purpose of this initialization is to check on the existence
%       of an 'options.txt' file in the working directory, and to parse the
%       same for the name of the curvature overlay file. This overlay is
%       opened to determine the number of vertices in the underlying surface.
%       
% PRECONDITIONS
%
%	o the autodijk class instance must be fully instantiated.
%
% POSTCONDITIONS
%
%       o the relevant 'Input sources' section of the class are defined.
%       o the internal overlay vector is initiated.
%
% NOTE:
%
% HISTORY
% 02 November 2009
% o Initial design and coding.
%

%%%%%%%%%%%%%%
%%% Nested functions
%%%%%%%%%%%%%%

function dir_create(astr_dir)
        [ret str_console] = unix(sprintf('mkdir -p %s', astr_dir));
        if ret
            vprintf(c, 1, 'While attempting to create %s', astr_dir);
            error_exit(c, '1', 'Could not create working dir')
        end
end

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%


C.mstack_proc 	        = push(C.mstack_proc, 'subject_preprocess');
verbosityLevel          = C.m_verbosityLevel;
C.m_verbosityLevel      = 2;

cd(C.mstr_workingDir);
C.mstr_workingDir       = pwd;  % Make sure we have an absolute dir spec

lprintf(C, 'Checking for <options.txt>');
if exist(C.mstr_optionsFile)
    str_parseCmd        =                                               ...
        sprintf('cat %s | grep curvatureFile | awk -F= %s{print $2}%s',...
                C.mstr_optionsFile, char(39), char(39));
    [str_ret, str_console]      = unix(str_parseCmd);
    str_console                 = strtrim(str_console);
    colprintf(C, '', '[ ok ]\n');
    C.mstr_curvatureFileName    = str_console;
    lprintf(C, 'Reading and parsing curvature file...');
    [C.mv_output, C.mfnum]      = read_curv(C.mstr_curvatureFileName);
    C.mv_output                 = C.mv_output * 0.0;
    colprintf(C, '', '[ ok ]\n');
    colprintf(C, 'Number of vertices', '[ %d ]\n', numel(C.mv_output));
    if C.mb_endOverride
        if C.mvertex_end >= numel(C.mv_output)
            C.mvertex_end       = numel(C.mv_output)-1;
        end
    else
        C.mvertex_end           = numel(C.mv_output)-1;
    end
    colprintf(C, 'Vertex POLE', '[ %d ]\n', C.mvertex_polar);
    colprintf(C, 'Vertex START', '[ %d ]\n', C.mvertex_start);
    colprintf(C, 'Vertex increment', '[ %d ]\n', C.mvertex_step);
    colprintf(C, 'Vertex END', '[ %d ]\n', C.mvertex_end);

else
    error_exit(C, '1', 'Could not find %s file to parse.', C.mstr_optionsFile);
end


C.m_verbosityLevel       = verbosityLevel;
[C.mstack_proc, element] = pop(C.mstack_proc);

end