function [C, adata, a_status] = map_process(C, fh, varargin)
%
% NAME
%
%  function [C, a_status, adata] = map_process(C, @fh [, ...])
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
%       This method is the main engine for navigating through the internal
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
% 25 September 2009
% o Initial design and coding.
%

C.mstack_proc 	= push(C.mstack_proc, 'map_process');

a_status        = 0;
adata           = [];
process_count   = 0;

% Use global array rather than class members because then the data
% does not need to be copied when calling class member functions.  This
% was strictly for performance reasons.
global g_arr_data;

% Create distributed arrays which will be used to distribute the workload
% across multiple "labs" (workers)
arr_dataCopy = distributed(g_arr_data);
arr_processCopy = distributed(C.arr_process);

% This is the main parallel loop.  The global arrays are broken up across
% the workers and each one computes its local data which is finally
% gathered back into the original global arrays
spmd
    coData = getCodistributor(arr_dataCopy);
    
    % Get the local arrays for this worker
    localData = getLocalPart(arr_dataCopy);
    
    localProcess = getLocalPart(arr_processCopy);
    
    % Process the elements for just this worker
    for process_num=1:numel(localData)
        [~, localData{process_num}] = ...
                fh(C, localProcess{process_num}, localData{process_num});
    end
    
    % These cause the data to be "gathered" on the worker
    arr_dataCopy = codistributed.build(localData, coData);
    
end

% Finally, gather the data back on the client
g_arr_data = gather(arr_dataCopy);

    
[C.mstack_proc, element] = pop(C.mstack_proc);

