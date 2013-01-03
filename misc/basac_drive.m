function [c]    = basac_drive(varargin)

    str_startDir        = pwd;
    str_dataDir         = pwd;

    if length(varargin) >= 1, str_dataDir       = varargin{1};          end
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
