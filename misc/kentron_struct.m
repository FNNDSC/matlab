function [s_kentron] = kentron_struct(	str_colorFileDir,	...
					str_brainMRItr,		...
					str_wmMRItr,		...
					str_filledMRItr)
%
% NAME
%
%  function [s_kentron] = kentron_struct(	str_colorFileDir,	...
%  						str_brainMRItr,		...
%  						str_wmMRItr,		...
%  						str_filledMRItr)
%
% ARGUMENTS
%
%       INPUTS                  TYPE            DESC
%	str_colorFileDir	string		directory containing the
%							colorfiles.
%	str_brainMRItr		string		filename containing the 
%							brain mritr data
%	str_wmMRItr		string		filename containing the 
%							wm mritr data
%	str_filledMRItr		string		filename containing the 
%							filled mritr data
%
%       OUTPUTS
%       s_otl			struct          All the inputs combined into
%                                                       a structure.
% DESCRIPTION
%
%       'otl_struct' is a struct "constructor" in as much as it accepts a group
%       of input argments and packs them into a struct, which is returned
%       to the caller. The idea of this struct is to be used as an input
%       argument to the motl2cor function controller, condensing several
%       arguments into one.
%
%       The struct field names are the same as the input variable names.
%
% PRECONDITIONS
%
%       o This struct is used ultimately with the motl2cor function.
%
% POSTCONDITIONS
%
%       o A populated struct is returned.
%
% HISTORY
%
% 19 January 2006
% o Initial design and coding.
%

c       = cell(1, 4);
c{1}    = str_colorFileDir;
c{2}    = str_brainMRItr;
c{3}    = str_wmMRItr;
c{4}    = str_filledMRItr;

s_otl = struct( 'str_colorFileDir',	c{1},   ...
                'str_brainMRItr',	c{2},   ...
                'str_wmMRItr',		c{3},   ...
                'str_filledMRItr',	c{4});

