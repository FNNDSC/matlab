function C = autodijk_process(C, varargin)
%
% NAME
%
%  function C = autodijk_process(C)
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze  class
%
% OPTIONAL
%
% OUTPUT
%	C		class		curvature_analyze class
%	
%
% DESCRIPTION
%
%	This method is the main entry point to "running" a curvature_analyze
%	class instance. It controls the main processing loop, viz. 
%
%               - populating internal subject info cell array
%               - creating the main data map that holds curvatures and processed
%                 information
%
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
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

C.mstack_proc 	= push(C.mstack_proc, 'autodijk_process');

switch C.mstr_runType
    case {'polar'}
        C = polar_analyze(C);
    otherwise
        error_exit(C, '10', 'Unknown run type');
end

[C.mstack_proc, element] = pop(C.mstack_proc);

