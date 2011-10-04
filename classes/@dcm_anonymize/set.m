function c = set(c, varargin)
%
% NAME
%
%  function c = set(c, 	  <astr_property1>, <val1> 	...
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
%	c		class		modified class
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
% 04 April 2008
% o Initial design and coding.
%

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
   case 'lsArg'
	c.mstr_dirArg			= val;
   case 'dicomInputDir'
	c.mstr_dicomInputDir		= val;
   case 'dicomInputFile'
	c.mstr_dicomInputFile		= val;
   case 'dicomOutputDir'
	c.mstr_dicomOutputDir		= val;
   case 'dicomOutputFile'
	c.mstr_dicomOutputFile		= val;
   case 'b_newSeries'
	c.mb_newSeries			= val;
   case 'verbosity'
	c.m_verbosity			= val;
   case 'SeriesDescription'
	c.mstr_SeriesDescription	= val;
   case 'SeriesNumber'
	c.m_SeriesNumber		= val;
   case 'anonPrefix'
	c.mstr_anonPrefix		= val;
   case 'keep'
	if strcmp(val, 'reset')
	    c.c_keep			= {};
	else
	    c.c_keep{numel(c.c_keep)+1}	= val;
	end

   otherwise
        error('dcm_anonymize Properties: set error');
   end
end

