function [c] 	= dcm_anonymize_drive()
	c	= dcm_anonymize();
	str_in	= '/space/kaos/1/users/dicom/files/TrioTim-35288-20090319-150142-281000';
	str_out	= '/space/kaos/1/users/rudolph/tmp';
	c	= set(c, 'dicomInputDir',	str_in);
	c	= set(c, 'dicomOutputDir',	str_out);
	c	= set(c, 'verbosity',		10);
	c	= set(c, 'b_newSeries',		0);
	c	= set(c, 'keep', 'reset');
	c	= set(c, 'keep', 'PatientAge');
	c	= set(c, 'keep', 'PatientSex');
	c	= set(c, 'keep', 'StudyDescription');
	c	= set(c, 'keep', 'SeriesDescription');
	c	= set(c, 'keep', 'ProtocolName');
	
	c	= run(c);
	
	cd(str_wd);
end
