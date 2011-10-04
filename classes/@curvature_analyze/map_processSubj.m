function [C, adata, a_status] = map_processSubj(C, fh, varargin)
%
% NAME
%
%  function [C, a_status, adata] = map_processSubj(C, @fh [, ...])
%
% ARGUMENTS
% INPUT
%	C		class		        curvature_analyze class
%       fh              function handle         a function that is passed the
%                                               map index as the main
%                                               function loops. This function
%                                               accepts the map index string,
%                                               and returns a status and data.
%      ...              any                     data to be send to each reference
%                                               function handle
%
% OPTIONAL
%
% OUTPUT
%       C               class           curvature_analyze  class
%       adata           any             data that is returned by the function
%                                       referenced by 'fh'
%       a_status        int             function return status.
%
% DESCRIPTION
% 
%       (NOTE: map_processSubj is conceptually identical to map_process,
%       differing only in the order of its looping. In this instance, the
%       inner-most (fastest) loop is the subject-loop).
% 
%       This method is an alternative engine for navigating through the main
%       map structure. It visits each map reference in turn, creating
%       a string map index for the reference and passing this reference
%       to the call-back function handle, <fh>, as well as the <varargin>
%       arguments.
%       
%       Map indices are of the form
%
%               <hemi>.<curvFunc>.<subj>.<region>.<surfaceType>.<coreData>
%
%       and a typical index is 'rh.K.730.entire.smoothwm.curvature'. where 'K'
%       denotes the curvature function, and '730' is the subject name.       
%       
%       The callback function executed at each map index has a fixed return
%       signature:
%       
%                       [ C, adata, a_status ]
%      
%       denoting the class itself, some arbitrary data, and a status code.
%
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%
% POSTCONDITIONS
%
%       o <adata> referenced by the index.
%       o boolean <a_status>.
%       
% NOTE:
%
% HISTORY
% 1 October 2009
% o Initial design and coding.
%

C.mstack_proc 	= push(C.mstack_proc, 'map_processSubj');

% Use global array rather than class members because then the data
% does not need to be copied when calling class member functions.  This
% was strictly for performance reasons.
global g_arr_data;


for process_num=1:C.arr_processCount
    subjIndex = C.arr_processSubjIndex(process_num);
        
    [C, g_arr_data{subjIndex}] = ...
        fh(C, C.arr_process{subjIndex}, g_arr_data{subjIndex});
end


a_status        = 0;
adata           = [];


[C.mstack_proc, element] = pop(C.mstack_proc);

