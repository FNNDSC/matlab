function [s_otl] = otlColor_struct(varargin)
%
% NAME
%
%  	function [s_otl] = otl_struct(	[str_colorFileDir,	...
%  					str_brainMRItr,		...
%  					str_wmMRItr,		...
%  					str_filledMRItr])
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
%       'otlColor_struct' is a struct "constructor" in as much as it accepts a 
%       group of input argments and packs them into a struct, which is returned
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

str_colorFileDir	= './colorfiles';
str_brainMRItr		= './colorfiles/tr_brain';
str_wmMRItr		= './colorfiles/tr_wm';
str_filledMRItr		= './colorfiles/tr_filled';

if length(varargin)
        str_colorFileDir		= varargin{1};
        if length(varargin) >= 2
                str_brainMRItr		= varargin{2};
        end
        if length(varargin) >= 3
                str_wmMRItr		= varargin{3};
        end
        if length(varargin) >= 4
                str_filledMRItr		= varargin{4};
        end
end

if length(varargin) == 1
	str_brainMRItr	= sprintf('%s/tr_brain', 	str_colorFileDir);
	str_wmMRItr	= sprintf('%s/tr_wm', 		str_colorFileDir);
	str_filledMRItr	= sprintf('%s/tr_filled', 	str_colorFileDir);
end

c       = cell(1, 4);
c{1}    = str_colorFileDir;
c{2}    = str_brainMRItr;
c{3}    = str_wmMRItr;
c{4}    = str_filledMRItr;

s_otl = struct( 'str_colorFileDir',	c{1},   ...
                'str_brainMRItr',	c{2},   ...
                'str_wmMRItr',		c{3},   ...
                'str_filledMRItr',	c{4});

