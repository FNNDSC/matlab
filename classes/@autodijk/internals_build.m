function C = internals_build(C, varargin)
%
% NAME
%
%  function C = internals_build(C)
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze class
%
% OPTIONAL
%
% OUTPUT
%	C		class		curvature_analyze class
%	
%
% DESCRIPTION
%
%       This function handles any internal housekeeping once the inputs
%       have been parsed.
%       
% PRECONDITIONS
%
%	o the autodijk class instance must be fully instantiated.
%       o a 'dsh' instance is started.
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

C.mstack_proc 	= push(C.mstack_proc, 'internals_build');

lprintf(C, 'Checking on <dsh>');
if ~exist(C.mscript_dsh)
    rprintf(C, '[ failure ]\n');
    error_exit(C, '20', 'No <dsh> script found!');
else
    rprintf(C, '[ ok ]\n');
end

lprintf(C, 'Checking on <backend>');
if ~exist(C.mexec_backend)
    rprintf(C, '[ failure ]\n');
    error_exit(C, '20', 'No <backend> engine found!');
else
    rprintf(C, '[ ok ]\n');
end

lprintf(C, 'Opening text output file %s...', C.mstr_outputTxtFile);
C.mfid_outputTxtFile    = fopen(C.mstr_outputTxtFile, 'w');
rprintf(C, '[ ok ]\n')

lprintf(C, 'Starting dsh --> backend infrastructure...');
str_dshInit             = sprintf('%s -e %s -c \"WGHT all get\"', C.mscript_dsh, C.mexec_backend);
[str_ret str_console]   = unix(str_dshInit);
rprintf(C, '[ ok ]\n');

[C.mstack_proc, element] = pop(C.mstack_proc);

