function C = set(C, varargin)
%
% NAME
%
%  function C = set(C, 	  <astr_property1>, <val1> 	...
%			[,<astr_property2>, <val2>	...
%			 ,<astr_propertyN>, <valN>
%			])
%
% ARGUMENTS
% INPUT
%	astr_propertM	string		Property string name
%	astr_valM	<any>		Property value
%
% OUTPUT
%	C		class		modified class
%
% OPTIONAL
%
% DESCRIPTION
%
%	'set' changes named internals of the class.
%
% NOTE:
%
% HISTORY
% 03 November 2009
% o Initial design and coding.
%

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val  = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
    case        'inputDir'
        C.mstr_inputDir                 = val;
    case	'outputDir'
	C.mstr_outputDir                = val;
    case	'outputFileName'
	C.mstr_outputFileName           = val;
        C.mstr_outputTxtFile            = sprintf('%s.txt', val);
    case        'dsh'
        C.mscript_dsh                   = val;
    case        'backend'
        C.mexec_backend                 = val;
    case        'step'
        C.mvertex_step                  = val;
    case        'start'
        C.mvertex_start                 = val;
    case        'end'
        C.mvertex_end                   = val;
        C.mb_endOverride                = 1;
    case        'pole'
        C.mvertex_polar                 = val;

   otherwise
        error('autodijk:Properties:set error');
   end
end

