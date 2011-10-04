function        [astr_hemi,             ...
                 astr_curvFunc,         ...
                 astr_subjName,         ...
                 astr_region,           ...
                 astr_surfaceType,      ...
                 astr_coreType,         ...
                 a_status] = map_indexSplit(C, astr_mapIndex)
%
% NAME
%
% function         [astr_hemi,     ...
%                   astr_curvFunc, ...
%                   astr_subj,     ...
%                   astr_region,   ...
%                   astr_coreType, ...
%                   a_status] = map_indexSplit(C, astr_mapIndex)
%  
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze class
%       astr_mapIndex   string          dot '.' delimited index
%
% OPTIONAL
%
% OUTPUT
%       astr_hemi               string          string components of the
%       astr_curvFunc           string          index lookup
%       astr_subj               string
%       astr_region             string
%       astr_surfaceType        string
%       astr_coreType           string
%       a_status                int             status information
%
% DESCRIPTION
%
%       This method simply splits its input <astr_mapIndex> into
%       its constituent parts. The index is defined according to:
%              
%               <hemi>.<curvFunc>.<subj>.<region>.<surfaceType>.<data>
%       
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%
% POSTCONDITIONS
%
%	o the components of the index lookup reference are returned.
%       o if any index lookup failed, a zero is returned in <a_status>
%
% NOTE:
%
% HISTORY
% 28 September 2009
% o Initial design and coding.
%

C.mstack_proc 	= push(C.mstack_proc, 'map_indexSplit');

astr_hemi               = '';
astr_curvFunc           = '';
astr_subjName           = '';
astr_region             = '';
astr_surfaceType        = '';
astr_coreType           = '';
a_status                = 0;

[astr_hemi,             str_rem] = strtok(astr_mapIndex, '.');
[astr_curvFunc,         str_rem] = strtok(str_rem, '.');
[astr_subjName,         str_rem] = strtok(str_rem, '.');
[astr_region,           str_rem] = strtok(str_rem, '.');
[astr_surfaceType,      str_rem] = strtok(str_rem, '.');
a_status                 = length(str_rem);
if ~length(a_status) return; end
[astr_coreType, str_rem] = strtok(str_rem, '.');
a_status                = length(astr_coreType);

[C.mstack_proc, element] = pop(C.mstack_proc);

