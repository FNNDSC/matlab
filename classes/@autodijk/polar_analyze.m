function C = polar_analyze(C, varargin)
%
% NAME
%
%	function [C] = polar_analyze(C)
%
% ARGUMENTS
%
%	INPUT
%       C               class                   autodijk class
%
%	OUTPUT 
%       C               class                   autodijk class
%
% DESCRIPTION
%
%	'polar_analyze' is the class method controlling a 'polar' dijkstra
%       analysis. It essentially computes the cost in traveling from a single
%       vertex (the 'polar point') to every other vertex on the surface, based
%       on the primary curvature overlay as specified in the <optionsFile>.
%
% PRECONDITIONS
%
%       o autodijk must be fully instantiated.
%       o 'dsh' must exist and be on the path.
%       o 'mris_pmake' must exist and be on the path.
% 
% SEE ALSO
%
% HISTORY
% 02 November 2009
% o Initial design and coding -- adapting from stand-alone non-class version.
%

%%
%% Nested Functions -- START
%%

function f_cost = cost_compute(a_vertexStart, a_vertexEnd)
    %
    % ARGS
    % INPUT
    % a_vertexStart, a_vertexEnd        int     start and end vertex indices
    % 
    % OUTPUT
    % af_cost                           float   cost of moving along optimal
    %                                           dijkstra path between these
    %                                           vertices
    % 
    % DESC
    % This function constructs the call to 'dsh' and interprets the results
    % from 'dsh'.
    %
    str_dsh     = '';
    str_dsh     = sprintf('%s; ENV costFunctionIndex set 0', str_dsh);
    str_dsh     = sprintf('%s; SURFACE active set 0', str_dsh);
    str_dsh     = sprintf('%s; VERTEX start set %d', str_dsh, a_vertexStart);
    str_dsh     = sprintf('%s; VERTEX end set %d', str_dsh, a_vertexEnd);
    str_dsh     = sprintf('%s; RUN', str_dsh);
    str_dsh     = sprintf('%s; SURFACE active ripClear', str_dsh);

    str_ret     = '0';
    str_console = 'void';
    [str_ret str_cost]          = dsh_exec(C, str_dsh);
    f_cost                      = str2num(str_cost);
end

%%
%% Nested Functions -- END
%% 

C.mstack_proc           = push(C.mstack_proc, 'polar_analyze');
verbosityLevel          = C.m_verbosityLevel;
C.m_verbosityLevel      = 2;

f_cost  = 0.0;

for vertex = C.mvertex_start:C.mvertex_step:C.mvertex_end
    lprintf(C, 'Cost in moving from %d to %d...', C.mvertex_polar, vertex);
    % The cost computation is calculated in a different executable and
    % result delivered by UDP comms. Occasionally the comms fail. Current
    % workaround is to wait a few seconds and rety the assignment.
    if C.mvertex_polar == vertex
        f_cost          = 0.0;
    else
        f_cost          = cost_compute(C.mvertex_polar, vertex);
    end
    b_comsError         = 1;
    while b_comsError
        try
            C.mv_output(vertex+1) = f_cost;
            b_comsError = 0;
        catch
            lprintf(C, 'Comms error caught. Retrying assignment...\n');
            pause(5);
            b_comsError = 1;
            f_cost      = cost_compute(C.mvertex_polar, vertex);
        end
    end
    rprintf(C, '[ %f ]', f_cost);
    fprintf(C.mfid_outputTxtFile, '%d\t%f\n', vertex, f_cost);
    if(C.m_verbosityLevel <= C.m_verbosity)
        for b = 1:80, fprintf(1, '\b'); end
    end
end

lprintf(C, '\n');
C.m_verbosityLevel      = verbosityLevel;
[C.mstack_proc, element] = pop(C.mstack_proc);
end