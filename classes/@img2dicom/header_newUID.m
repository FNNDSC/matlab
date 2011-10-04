function [c] = header_newUID(c)
%
% NAME
%
%	function [c] = header_newUID(c)
%
% ARGUMENTS
% INPUT
%	c		class		dcm_anonymize
%
% OPTIONAL
%	
%
% DESCRIPTION
% 
%	Updates several fields in a dicom data structure with new
%	series and study information
%
% PRECONDITIONS
%
%	o 'hash' function
%
% POSTCONDITIONS
% 
% 	o Updates:
% 		- StudyInstanceUID
% 		- SeriesInstanceseriesUID
%
% NOTE:
%
% HISTORY
% 20 March 2009
% o Initial design and coding.
%

c.mstack_proc 	= push(c.mstack_proc, 'header_newUID');

cprint(c, 'New SeriesDescription', c.mstr_SeriesDescription);
c.m_SeriesInstanceUID	= c.mDicomInfo.SeriesInstanceUID;
if c.mb_newSeries
  c.m_SeriesInstanceUID	= dicomuid;
  cprint(c, 'New SeriesInstanceUID', c.m_SeriesInstanceUID);
  c.mDicomInfo.SeriesInstanceUID 	= c.m_SeriesInstanceUID;
  c.mDicomInfo.StudyInstanceUID		= c.m_SeriesInstanceUID;
  c.mDicomInfo.SeriesInstanceseriesUID	= c.m_SeriesInstanceUID;

  % Capture the last SeriesInstance Field
  [status lastField]		= 				...
	unix(sprintf('echo %s | awk -F. %s{print $12}%s',	...
			c.m_SeriesInstanceUID, char(39), char(39)));
  c.mDicomInfo.SeriesNumber	= c.m_SeriesNumber;
  cprint(c, 'New SeriesNumber', sprintf('%d', c.m_SeriesNumber));  
end

c.s_updateDicomInfo.PatientName			= 'anonymized';
c.s_updateDicomInfo.PatientBirthDate		= '19000101';
c.s_updateDicomInfo.PatientID			= hash(c.mDicomInfo.PatientID, 'md2');
c.s_updateDicomInfo.StudyInstanceUID		= c.m_SeriesInstanceUID;
c.s_updateDicomInfo.SeriesInstanceUID 		= c.m_SeriesInstanceUID;
c.s_updateDicomInfo.StudyInstanceUID		= c.m_SeriesInstanceUID;
c.s_updateDicomInfo.SeriesInstanceseriesUID	= c.m_SeriesInstanceUID;
%  c.s_updateDicomInfo.SeriesNumber		= c.m_SeriesNumber;
c.s_updateDicomInfo.ReasonForStudy		= '';

[c.mstack_proc, element]= pop(c.mstack_proc);
