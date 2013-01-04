function [c]    = basac_drive(varargin)
%
% NAME
% 
%       basac_drive
%       
% SYNOPSIS
% 
%       basac_drive(    [<str_dataDir>,
%                       [<f_stdOffsetASL>,
%                       [<f_stdOffsetADC>,
%                       [<f_stdOffsetADCCSF>]]]])
%       
% ARGS
%
%       str_dataDir             string  directory containing pre-processed
%                                       ADC and ASL volumes
%       f_stdOffsetASL          float   deviation offset for the ASL (-2.5)
%       f_stdOffsetADC          float   deviation offset for the ADC (-2.5)
%       f_stdOffsetADCCSF       float   deviation offset for the CSF
%                                       suppression in the ADC vol (+1.5)
% DESC
% 
%       'basac_drive' is a simple driver for a B0, ASL, ADC analysis. It will
%       attempt to find co-located regions of high deviation signal in both the
%       ADC and ASL volumes of a pre-processed dataset. By default, the analysis
%       looks for co-located _low_ ADC intensity and _high_ ASL intensity.
%       
%       The deviation profiles can be tweaked using optional arguments.
%       
% EXAMPLES
% 
%       In the following, assume that the directory containing pre-processed
%       volumes is called 'outDir':
%       
%       o Example 1: Default -- look for _low_ ADC co-located with _high_ ASL:
%       
%               >>basac_drive('outDir');
%               
%       o Example 2: Same as above, but with explicit offset specs:
%       
%               >>basac_drive('outDir', -2.5, -2.5);
%               
%       o Example 3: Look for _low_ ADC co-located with _low_ ASL:
%       
%               >>basac_drive('outDir', +2.5, -2.5);
%               
%       o Example 4: Look for _high_ ADC co-located with _low_ ASL:         
%               
%               >>basac_drive('outDir', +2.5, +2.5);
%
%       o Example 5: Look for _high_ ADC co-located with _high_ ASL:
%       
%               >>basac_drive('outDir', -2.5, +2.5);
%            

    str_startDir        = pwd;
    str_dataDir         = pwd;

    f_stdOffsetASL      = -2.5; % The deviation offset for ASL
                                % Note that a *negative* offset in the case of 
                                % ASL is taken to mean a positive deviation. To
                                % search for ASL regions *less* than the normal
                                % mean, set this offset to positive.
    f_stdOffsetADC      = -2.5; % The deviation offset for ADC
    f_stdOffsetADCCSF   =  1.5; % The CSF suppression offset
    
    if length(varargin) >= 1,   str_dataDir             = varargin{1};  end
    if length(varargin) >= 2,   f_stdOffsetASL          = varargin{2};  end
    if length(varargin) >= 3,   f_stdOffsetADC          = varargin{3};  end
    if length(varargin) >= 4,   f_stdOffsetADCCSF       = varargin{4};  end
    cd(str_dataDir);

    c = basac_process();
    c = basac_initialize(c, 'default');

    c = set(c, 'b0_dir',                        pwd);
    c = set(c, 'b0_file',                       'b0Brain_mask.nii.gz');
    c = set(c, 'asladc_dir',                    pwd);
    c = set(c, 'asl_file',                      'aslB0Mask_float_gte0_norm.nii');
    c = set(c, 'adc_file',                      'adcB0Mask_float_gte0_norm.nii');
    c = set(c, 'asl_orig',                      'aslB0Mask_float_gte0.nii');
    c = set(c, 'adc_orig',                      'adcB0Mask_float_gte0.nii');
    c = set(c, 'asl_origScale',                 0.1);
    c = set(c, 'adc_origScale',                 1.0);

    c = set(c, 'mb_ADCsuppressCSF',              1);
    c = set(c, 'stdOffsetADCCSF',                1.5);
    c = set(c, 'stdOffsetADC',                  -2.5);
    c = set(c, 'stdOffsetASL',                  -2.5);
    c = set(c, 'filterOnRawROI',                0);

    c = set(c, 'binarizeMasks',                 1);
    c = set(c, 'registrationPenalize',          1);
    c = set(c, 'registrationPenalizeFunc',      'sigmoid');
    c = set(c, 'ROIfilterCount',                -1);
    
    c = set(c, 'kernelADC',                     7);
    c = set(c, 'kernelASL',                     11);

    c = set(c, 'showVolumes',                   0);
    c = set(c, 'showScatter',                   0);
    c = set(c, 'showMaxCorrelation',            0);
    c = set(c, 'mb_imagesSave',                 0);

    c = run(c);
    cd(str_startDir);
end
