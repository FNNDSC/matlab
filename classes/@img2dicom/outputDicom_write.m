function [c] = outputDicom_write(c)
%
% NAME
%
%	function [c] = name(c)
%
% ARGUMENTS
% INPUT
%	c		class		img2dcm class
%
% OPTIONAL
%
% DESCRIPTION
%
%	Saves the contents of c.mcell_img to a set of dicom files
%	in c.mstr_outputDicomDir
%
% PRECONDITIONS
%
%	o c.mcell_img must be populated
%	o c.mDicomInfo must be defined
%
% POSTCONDITIONS
%
%	o Each image in c.mcell_img is saved in dicom format
%	  to c.mstr_outputDicomDir.
%
% NOTE:
%
% HISTORY
% 10 April 2008
% o Initial design and coding.
%
% 17 April 2008
% o Added some extentions to c.mDicomInfo:
%	- InstanceNumber
%	- AcquisitionNumber
%	- SeriesDescription
%

c.mstack_proc 	= push(c.mstack_proc, 'outputDicom_write');

cd(c.mstr_dicomOutputDir);

LC_orig			= c.m_marginLeft;
RC_orig			= c.m_marginRight;
c.m_marginLeft		= 22;
c.m_marginRight		= 65;

cprint(c, 'New SeriesDescription', c.mstr_SeriesDescription);
if c.mb_newSeries
  c.m_SeriesInstanceUID	= dicomuid;
  cprint(c, 'New SeriesInstanceUID', c.m_SeriesInstanceUID);
  c.mDicomInfo.SeriesInstanceUID = c.m_SeriesInstanceUID;
  % Capture the last SeriesInstance Field
  [status lastField]		= 				...
	unix(sprintf('echo %s | awk -F. %s{print $12}%s',	...
			c.m_SeriesInstanceUID, char(39), char(39)));
  c.mDicomInfo.SeriesNumber	= c.m_SeriesNumber;
  cprint(c, 'New SeriesNumber', sprintf('%d', c.m_SeriesNumber));
end


imageNum	= length(c.mcell_img);
c.mDicomInfo.SeriesDescription	= c.mstr_SeriesDescription;
sys_print(c, sprintf('| Writing DICOM format... '));
for i=1:imageNum
	c.mDicomInfo.AcquisitionNumber 	= i;
	c.mDicomInfo.InstanceNumber	= i;
	str_dicomFileName	= sprintf('%s.dcm', c.mcell_imgFileName{i});
	str_info = sprintf('%04d/%04d: %s    ', i, imageNum, str_dicomFileName);
	vprintf(c, 1, str_info);
	dicomwrite(c.mcell_img{i}, str_dicomFileName, c.mDicomInfo);
	str_b	= '';
	for b=1:length(str_info)
	    str_b = sprintf('%s%s', str_b, '\b');
	end
	vprintf(c, 1, str_b);
end
vprintf(c, 1, '\n');
sys_print(c, sprintf('| %s images written to dicom output directory.\n'), ...
		 length(c.mcell_img));

cd(c.mstr_workingDir);
c.m_marginLeft		= LC_orig;
c.m_marginRight		= RC_orig;
[c.mstack_proc, element]= pop(c.mstack_proc);
