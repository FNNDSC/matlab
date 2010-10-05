clear classes;
c               = basac_process();
c               = basac_initialize(c, 'default');

cd('/autofs/space/kaos_005/users/dicom/postproc/4468137/asladc/asladc-2-bet');
c               = set(c, 'b0_dir',  pwd);
c               = set(c, 'b0_file', 'B0_brain_mask.img');

cd('../asladc-4-mri_convert');
c               = set(c, 'asladc_dir',  pwd);
c               = set(c, 'asl_file',    'ASL-B0_masked.f.norm.mgz');
c               = set(c, 'adc_file',    'ADC-B0_masked.f.norm.mgz');

c               = set(c, 'showVolumes',         0);
c               = set(c, 'showScatter',         1);
c               = set(c, 'showMaxCorrelation',  1);
c               = set(c, 'mb_imagesSave',       1);

c               = run(c);
s               = struct(c);

