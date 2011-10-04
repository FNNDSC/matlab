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
    case	'registrationPenalizeFunc'
	c.mstr_registrationPenalizeFunc	= val;
    case	'meanMaskTolerance'
	c.mf_meanMaskTolerance		= val;
    case	'ROIfilterCount'
	c.m_ROIfilterCount		= val;
    case	'registrationPenalize'
	c.mb_registrationPenalize	= val;
    case	'binarizeMasks'
	c.mb_binarizeMasks		= val;
    case        'asladc_dir'
        c.mstr_asladcInputDir           = val;
    case        'asl_file'
        c.mstr_aslInputFile             = val;
    case        'adc_file'
        c.mstr_adcInputFile             = val;
    case        'asl_orig'
        c.mstr_aslOrigFile              = val;
    case        'adc_orig'
        c.mstr_adcOrigFile              = val;
    case        'adc_origScale'
        c.mf_ADCorigScale               = val;
    case        'asl_origScale'
        c.mf_ASLorigScale               = val;
    case        'b0_dir'
        c.mstr_b0MaskInputDir           = val;
    case        'b0_file'
        c.mstr_b0MaskInputFile          = val;
    case        'verbosity'
	c.m_verbosity			= val;
    case        'mb_invASL'
        c.mb_invASL                     = val;
    case        'mb_ADCsuppressCSF'
        c.mb_ADCsuppressCSF		= val;
    case        'showVolumes'
        c.mb_showVolumes                = val;
    case        'showScatter'
        c.mb_showScatter                = val;
    case        'showMaxCorrelation'
        c.mb_showMaxCorrelation         = val;
    case        'mb_imagesSave'
        c.mb_imagesSave                 = val;
    case        'stdOffsetASL'
        c.mf_stdOffsetASL               = val;
    case        'stdOffsetADC'
        c.mf_stdOffsetADC               = val;
    case        'stdOffsetADCCSF'
        c.mf_stdOffsetADCCSF		= val;
    case        'kernelASL'
        c.mM_kernelASL                  = [ val val ];
    case        'kernelADC'
        c.mM_kernelADC                  = [ val val ];

   otherwise
        error('basac_process:Properties:set error');
   end
end

