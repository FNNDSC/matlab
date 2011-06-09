function [aS_ct] = mris_colorTableMake( a_labelVar, varargin)
%
% NAME
% function [aS_ct] = mris_colorTableMake( a_labelVar, varargin)
%
% $Id:$
%
%
% ARGUMENTS
%       
%       INPUT
%       a_labelVar      var             multi-type:
%                                       + int: number of labels
%                                       + cstr_labelName: cell list of label
%                                                         names
%
%       OPTIONAL
%
%       OUTPUT
%       aS_ct           struct          color table structure
%
% DESCRIPTION
%
%       'mris_colorTableMake' constructs a color table structure.
%       
%       In the simplest case, its input argument is an integer denoting
%       the size of the table, in which case the script names labels
%       'region-1', 'region-2', ... 'region-N'.
%       
%       Alternatively, a cell array of strings can be passed, in which
%       case these are used as label names and also define the size
%       of the table.
%              
% PRECONDITIONS
%       o FreeSurfer environment.
%
% POSTCONDITIONS
%       o FreeSurfer colortable struct is returned.
%         
% SEE ALSO
%       o read_annotation / write_annotation for a description of the
%         color table format.
%
% HISTORY
% 07 June 2011
% o Initial design and coding.
%

% ---------------------------------------------------------

sys_printf('mris_colorTableMake: START\n');
 

% Parse optional arguments

% Determine the table size
b_labelNames    = 0;
if (isfloat(a_labelVar))
    tableSize   = int32(a_labelVar);
end
if (iscell(a_labelVar))
    tableSize   = numel(a_labelVar);
    b_labelNames = 1;
end

% Build the color table using permutations in the [256 256 256] space
dimension       = 0;
rows            = 0;
while rows < tableSize
    dimension   = dimension + 1;
    [I, D]      = permutations_find(3, dimension, [128 128 128]);
    [rows cols] = size(I{dimension});
end

M_RGBfull       = int32(normalize(I{dimension})*256);
% Skip the first _RGBfull entry which is [ 0 0 0 ]
M_RGB           = M_RGBfull(2:tableSize+1, :);

v_index         = [1:tableSize];
M_ct            = double([M_RGB zeros(tableSize, 1) v_index']);

% Label names
if (~b_labelNames)
    Cstr_labelName = cell(tableSize, 1);
    for i=1:tableSize
        Cstr_labelName{i}       = sprintf('region-%d', i);
    end
else
    Cstr_labelName              = a_labelVar;
end

aS_ct                   = struct;
aS_ct.numEntries        = tableSize;
aS_ct.orig_tab          = 'none';
aS_ct.struct_names      = Cstr_labelName;
aS_ct.table             = M_ct;

sys_printf('mris_colorTableMake: END\n');

end
% ---------------------------------------------------------


